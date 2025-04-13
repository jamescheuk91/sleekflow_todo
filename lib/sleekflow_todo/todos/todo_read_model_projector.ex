defmodule SleekFlowTodo.Todos.TodoReadModelProjector do
  use Commanded.Projections.Ecto,
    application: SleekFlowTodo.CommandedApplication,
    repo: SleekFlowTodo.ProjectionRepo,
    name: "TodosTodoReadModelProjector",
    consistency: :strong

  require Logger

  alias SleekFlowTodo.Todos.Events.TodoAdded
  alias SleekFlowTodo.Todos.Events.TodoEdited
  alias SleekFlowTodo.Todos.Events.TodoRemoved
  alias SleekFlowTodo.Todos.TodoReadModel

  project(%TodoAdded{} = event, _metadata, fn multi ->
    # Convert status/priority strings from event data to atoms if necessary
    status_atom = if is_binary(event.status), do: String.to_existing_atom(event.status), else: event.status
    priority_atom = if is_binary(event.priority), do: String.to_existing_atom(event.priority), else: event.priority

    # Use the parsed DateTime structs when creating the TodoReadModel
    struct = %TodoReadModel{
      id: event.todo_id,
      name: event.name,
      description: event.description,
      status: status_atom,
      priority: priority_atom,
      due_date: event.due_date,
      tags: event.tags,
      added_at: event.added_at
    }

    # Pass the struct directly to Ecto.Multi.insert
    Ecto.Multi.insert(multi, :insert_todo_read_model, struct)
  end)

  project(%TodoEdited{} = event, _metadata, fn multi ->
    todo = SleekFlowTodo.ProjectionRepo.get!(TodoReadModel, event.todo_id)

    attrs =
      Map.from_struct(event)
      |> Map.put_new(:tags, nil)
      |> Map.update(:status, nil, fn
        # Keep it nil if it's nil initially
        nil -> nil
        # Convert if it's a string
        status_str when is_binary(status_str) -> String.to_existing_atom(status_str)
        # Keep it if it's already an atom
        atom when is_atom(atom) -> atom
      end)
      |> Map.update(:priority, nil, fn
        # Keep it nil if it's nil initially
        nil -> nil
        # Convert if it's a string
        priority_str when is_binary(priority_str) -> String.to_existing_atom(priority_str)
        # Keep it if it's already an atom (should always be)
        atom when is_atom(atom) -> atom
        # Log if it's somehow not an atom (should not happen)
        _ -> Logger.warning("Unexpected priority format in TodoEdited event: #{inspect(event.priority)}"); nil
      end)
      # Filter out keys where the value is nil *after* potential status conversion
      |> Enum.reject(fn {_, v} -> is_nil(v) end)
      |> Map.new()

    changeset = TodoReadModel.changeset(todo, attrs)
    Ecto.Multi.update(multi, :update_todo_read_model, changeset)
  end)

  project(%TodoRemoved{} = event, _metadata, fn multi ->
    case SleekFlowTodo.ProjectionRepo.get(TodoReadModel, event.todo_id) do
      nil ->
        Logger.error(
          "[TodoReadModelProjector] Received TodoRemoved for non-existent read model: #{event.todo_id}"
        )

        # Return multi unchanged if record not found
        multi

      todo ->
        Ecto.Multi.delete(multi, :delete_todo_read_model, todo)
    end
  end)
end

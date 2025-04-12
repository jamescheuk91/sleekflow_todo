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
    # Use the parsed DateTime structs when creating the TodoReadModel
    struct = %TodoReadModel{
      id: event.todo_id,
      name: event.name,
      description: event.description,
      status: String.to_existing_atom(event.status),
      due_date: event.due_date,
      added_at: event.added_at
    }

    # Pass the struct directly to Ecto.Multi.insert
    Ecto.Multi.insert(multi, :insert_todo_read_model, struct)
  end)

  project(%TodoEdited{} = event, _metadata, fn multi ->
    todo = SleekFlowTodo.ProjectionRepo.get!(TodoReadModel, event.todo_id)
    attrs =
      Map.from_struct(event)
      |> Map.update(:status, nil, fn
        nil -> nil # Keep it nil if it's nil initially
        status_str when is_binary(status_str) -> String.to_existing_atom(status_str) # Convert if it's a string
        atom when is_atom(atom) -> atom # Keep it if it's already an atom
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

        multi # Return multi unchanged if record not found

      todo ->
        Ecto.Multi.delete(multi, :delete_todo_read_model, todo)
    end
  end)

end

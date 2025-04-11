defmodule SleekFlowTodo.Todos.TodoReadModelProjector do
  use Commanded.Projections.Ecto,
    application: SleekFlowTodo.CommandedApplication,
    repo: SleekFlowTodo.ProjectionRepo,
    name: "TodosTodoReadModelProjector",
    consistency: :strong

  require Logger

  alias SleekFlowTodo.Todos.Events.TodoAdded
  alias SleekFlowTodo.Todos.Events.TodoEdited
  alias SleekFlowTodo.Todos.TodoReadModel

  project(%TodoAdded{} = event, _metadata, fn multi ->
    # Use the parsed DateTime structs when creating the TodoReadModel
    struct = %TodoReadModel{
      id: event.todo_id,
      name: event.name,
      description: event.description,
      status: event.status,
      due_date: event.due_date,
      added_at: event.added_at
    }

    # Pass the struct directly to Ecto.Multi.insert
    Ecto.Multi.insert(multi, :insert_todo_read_model, struct)
  end)

  project(%TodoEdited{} = event, _metadata, fn multi ->
    todo = SleekFlowTodo.ProjectionRepo.get!(TodoReadModel, event.todo_id)
    changeset = TodoReadModel.changeset(todo, event)
    Ecto.Multi.update(multi, :update_todo_read_model, changeset)
  end)

end

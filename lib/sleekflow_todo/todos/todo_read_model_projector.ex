defmodule SleekFlowTodo.Todos.TodoReadModelProjector do
  use Commanded.Projections.Ecto,
    application: SleekFlowTodo.CommandedApplication,
    repo: SleekFlowTodo.ProjectionRepo,
    name: "TodosTodoReadModelProjector"

  require Logger

  alias SleekFlowTodo.Todos.Events.TodoAdded
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
    Ecto.Multi.insert(multi, :todo_read_model, struct)
  end)
end

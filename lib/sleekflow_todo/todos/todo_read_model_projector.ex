defmodule SleekFlowTodo.Todos.TodoReadModelProjector do
  use Commanded.Projections.Ecto,
    application: SleekFlowTodo.CommandedApplication,
    repo: SleekFlowTodo.ProjectionRepo,
    name: "TodosTodoReadModelProjector"



  alias SleekFlowTodo.Todos.Events.TodoAdded
  alias SleekFlowTodo.Todos.TodoReadModel

  project(%TodoAdded{} = event, _metadata, fn multi ->
    # Create the struct data first
    data = %TodoReadModel{
      id: event.todo_id,
      name: event.name,
      description: event.description,
      status: event.status || "pending", # Provide default status if nil
      due_date: event.due_date,
      added_at: event.added_at
    }

    # Pass the struct directly to Ecto.Multi.insert
    Ecto.Multi.insert(multi, :todo_read_model, data)
  end)
end

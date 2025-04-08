defmodule SleekFlowTodo.Todos.Router do
  use Commanded.Commands.Router

  alias SleekFlowTodo.Todos.Aggregates.Todo
  alias SleekFlowTodo.Todos.Commands.AddTodo
  alias SleekFlowTodo.Todos.Commands.AddTodoHandler

  dispatch AddTodo, to: AddTodoHandler, aggregate: Todo, identity: :todo_id
end

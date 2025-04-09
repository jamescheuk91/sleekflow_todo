defmodule SleekFlowTodo.Todos.Commands.AddTodo do
  @moduledoc """
  A struct representingCommand to add a new todo item.
  """

  use TypedStruct

  typedstruct do
    @typedoc "A command to add a new todo item."
    field :todo_id, String.t(), enforce: true
    field :name, String.t(), enforce: true
    field :description, String.t()
    field :due_date, DateTime.t()
    field :added_at, DateTime.t(), enforce: true
  end
end

defmodule SleekFlowTodo.Todos.Commands.RemoveTodo do
  @moduledoc """
  Command to remove a todo item.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A command to remove a todo item."
    field :todo_id, String.t(), enforce: true
    field :removed_at, DateTime.t(), enforce: true
  end
end

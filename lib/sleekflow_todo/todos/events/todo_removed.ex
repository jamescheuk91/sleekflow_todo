defmodule SleekFlowTodo.Todos.Events.TodoRemoved do
  @moduledoc """
  Event indicating a todo item has been removed.
  """
  @derive Jason.Encoder
  use TypedStruct

  typedstruct do
    @typedoc "An event indicating a todo item has been deleted."
    field :todo_id, String.t(), enforce: true
    field :removed_at, DateTime.t(), enforce: true
  end
end

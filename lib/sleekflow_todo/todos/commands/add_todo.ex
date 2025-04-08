defmodule SleekFlowTodo.Todos.Commands.AddTodo do
  @moduledoc """
  Command to add a new todo item.
  """
  defstruct [:todo_id, :name, :description, :due_date, added_at: DateTime.utc_now()]

  @type t :: %__MODULE__{
          todo_id: String.t(),
          name: String.t(),
          description: String.t(),
          due_date: DateTime.t(),
          added_at: DateTime.t()
        }
end

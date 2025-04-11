defmodule SleekFlowTodo.Todos.Commands.EditTodo do
  @moduledoc """
  A struct representingCommand to edit a todo item.
  """

  use TypedStruct

  typedstruct do
    @typedoc "A command to edit a todo item."
    field :todo_id, String.t(), enforce: true
    field :name, String.t()
    field :description, String.t()
    field :due_date, DateTime.t()
    field :status, Ecto.Enum, values: [:not_started, :in_progress, :completed]
  end
end

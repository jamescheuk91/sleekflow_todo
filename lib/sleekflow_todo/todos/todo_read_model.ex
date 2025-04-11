# lib/sleekflow_todo/todos/todo_read_model.ex
defmodule SleekFlowTodo.Todos.TodoReadModel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  schema "todos" do
    # The primary key `:id` should correspond to the original Todo's ID
    # It's set to autogenerate: false as it's projected, not generated here.

    field :name, :string
    field :description, :string
    # Using string representation for flexibility in read model consumers
    field :status, Ecto.Enum, values: [:not_started, :in_progress, :completed]
    field :due_date, :utc_datetime_usec
    field :added_at, :utc_datetime_usec

    # Timestamps reflect when the projection was last updated
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:name, :description, :status, :due_date, :updated_at])
    # Add validations if needed for the read model specifically
  end
end

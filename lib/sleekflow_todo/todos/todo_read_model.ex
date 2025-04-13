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
    field :priority, Ecto.Enum, values: [:low, :medium, :high]
    field :due_date, :utc_datetime_usec
    field :tags, {:array, :string}
    field :added_at, :utc_datetime_usec

    # Timestamps reflect when the projection was last updated
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:name, :description, :status, :priority, :due_date, :tags])
    |> validate_required([:name, :status, :added_at])
    # Validate priority is one of the allowed values
    |> validate_inclusion(:priority, [:low, :medium, :high])
  end
end

defmodule SleekFlowTodo.ProjectionRepo.Migrations.CreateTodoProjectionsTable do
  use Ecto.Migration

  def change do
    create table(:todos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :string
      add :status, :string
      add :due_date, :utc_datetime_usec
      add :added_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec) # Adds inserted_at and updated_at
    end

    # Optional: Add an index if you frequently query by status
    # create index(:todo_projections, [:status])
  end
end

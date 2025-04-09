defmodule SleekFlowTodo.ProjectionRepo.Migrations.CreateTodoProjectionsTable do
  use Ecto.Migration

  def change do
    create table(:todos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :status, :string, null: false
      add :due_date, :utc_datetime_usec
      add :added_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec) # Adds inserted_at and updated_at
    end

    # Create index on status for efficient filtering
    create index(:todos, [:status])
    # Create index on due_date for efficient filtering and sorting
    create index(:todos, [:due_date])
    # Create index on added_at for efficient filtering and sorting
    create index(:todos, [:added_at])
  end
end

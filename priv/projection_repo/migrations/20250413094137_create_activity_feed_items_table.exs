defmodule SleekFlowTodo.ProjectionRepo.Migrations.CreateActivityFeedItemsTable do
  use Ecto.Migration

  def change do
    create table(:activity_feed_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :todo_id, :binary_id, null: false
      add :type, :string, null: false # Storing enum as string for flexibility
      add :details, :map, null: false
      add :occurred_at, :utc_datetime_usec, null: false

      # inserted_at only
      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create index(:activity_feed_items, [:todo_id])
    create index(:activity_feed_items, [:occurred_at])
  end
end

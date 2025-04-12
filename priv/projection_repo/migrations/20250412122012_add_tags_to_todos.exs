defmodule SleekFlowTodo.ProjectionRepo.Migrations.AddTagsToTodos do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add :tags, {:array, :string}, null: false, default: []
    end
  end
end

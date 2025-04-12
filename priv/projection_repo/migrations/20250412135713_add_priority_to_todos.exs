defmodule SleekFlowTodo.ProjectionRepo.Migrations.AddPriorityToTodos do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add :priority, :string, default: nil, null: true
    end
  end
end

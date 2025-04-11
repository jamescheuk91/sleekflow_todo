defmodule SleekFlowTodo.Todos.Commands.EditTodoTest do
  use ExUnit.Case, async: true

  alias SleekFlowTodo.Todos.Commands.EditTodo

  describe "new/1" do
    test "creates a command with valid data" do
      uuid = Commanded.UUID.uuid4()
      due_date = DateTime.utc_now() |> DateTime.truncate(:second)

      params = %{
        todo_id: uuid,
        name: "Buy groceries",
        description: "Milk, eggs, bread",
        due_date: due_date,
        status: :in_progress
      }

      assert %EditTodo{
               todo_id: ^uuid,
               name: "Buy groceries",
               description: "Milk, eggs, bread",
               due_date: ^due_date,
               status: :in_progress
             } = struct(EditTodo, params)
    end
  end
end

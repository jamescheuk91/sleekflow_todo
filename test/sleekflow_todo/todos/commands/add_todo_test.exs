defmodule SleekFlowTodo.Todos.Commands.AddTodoTest do
  use ExUnit.Case, async: true

  alias SleekFlowTodo.Todos.Commands.AddTodo

  describe "AddTodo command" do
    test "can be created with required fields" do
      id = Commanded.UUID.uuid4()
      added_at = DateTime.utc_now()
      todo = %AddTodo{todo_id: id, name: "Test Todo", added_at: added_at}
      assert todo.todo_id == id
      assert todo.name == "Test Todo"
    end

    test "optional fields can be nil" do
      id = Commanded.UUID.uuid4()
      added_at = DateTime.utc_now()
      todo = %AddTodo{todo_id: id, name: "Test Todo", added_at: added_at}
      assert is_nil(todo.description)
      assert is_nil(todo.due_date)
      # Default value is empty list
      assert todo.tags == []
      assert todo.added_at == added_at
    end

    test "can be created with tags" do
      id = Commanded.UUID.uuid4()
      added_at = DateTime.utc_now()
      tags = ["work", "urgent"]
      todo = %AddTodo{todo_id: id, name: "Test Todo", tags: tags, added_at: added_at}
      assert todo.tags == tags
    end
  end
end

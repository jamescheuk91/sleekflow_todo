defmodule SleekFlowTodo.Todos.GetTodoItemServiceTest do
  use SleekFlowTodo.DataCase, async: false

  alias SleekFlowTodo.Todos
  alias SleekFlowTodo.Todos.GetTodoItemService
  alias SleekFlowTodo.Todos.TodoReadModel

  describe "get_todo/1" do
    test "returns the todo item if it exists" do
      due_date_1 = DateTime.utc_now() |> DateTime.add(1, :day)
      now = DateTime.utc_now()

      {:ok, todo_id} =
        %{
          name: "Task A",
          description: "Description A",
          due_date: due_date_1,
          added_at: now,
          tags: ["tag1", "tag2"]
        }
        |> Todos.add_todo()

      assert %TodoReadModel{} = found_todo = GetTodoItemService.get_todo(todo_id)
      assert found_todo.id == todo_id
      assert found_todo.name == "Task A"
      assert found_todo.description == "Description A"
      assert found_todo.due_date == due_date_1
      assert found_todo.status == :not_started
      assert found_todo.tags == ["tag1", "tag2"]
    end

    test "returns nil if the todo item does not exist" do
      assert GetTodoItemService.get_todo(Commanded.UUID.uuid4()) == nil
    end
  end
end

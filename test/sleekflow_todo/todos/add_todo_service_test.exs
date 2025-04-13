defmodule SleekFlowTodo.Todos.AddTodoServiceTest do
  use SleekFlowTodo.DataCase, async: true

  alias SleekFlowTodo.Todos.AddTodoService

  describe "add_todo/1" do
    test "returns {:ok, todo_id} on successful command dispatch" do
      valid_attrs = %{
        name: "Buy milk",
        description: "Get soy milk from the store"
      }

      result = AddTodoService.add_todo(valid_attrs)

      assert {:ok, todo_id} = result
      assert is_binary(todo_id)
      # Basic check if it looks like a UUID without adding a dependency
      assert String.length(todo_id) == 36
      assert String.match?(todo_id, ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
    end

    test "returns {:error, {:unexpected, reason}} when required fields are missing" do
      # Missing :name which is required by AddTodo struct
      invalid_attrs = %{
        description: "Missing name"
      }

      result = AddTodoService.add_todo(invalid_attrs)

      # struct! raises KeyError which is caught by the 'other_error' clause
      assert {:error, {:unexpected, reason}} = result
      assert is_binary(reason)
      # Check that the reason mentions the KeyError and the missing key
      assert String.contains?(reason, "KeyError")
      assert String.contains?(reason, "key :name not found")
    end

  end
end

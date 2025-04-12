defmodule SleekFlowTodo.Todos.Commands.RemoveTodoHandlerTest do
  use SleekFlowTodo.DataCase, async: false

  alias SleekFlowTodo.Todos
  alias SleekFlowTodo.Todos.Aggregates.Todo
  alias SleekFlowTodo.Todos.Commands.{RemoveTodo, RemoveTodoHandler}
  alias SleekFlowTodo.Todos.Events.TodoRemoved

  describe "handle/2" do
    test "removes the todo when it exists" do
      next_day = DateTime.add(DateTime.utc_now(), 1, :day)

      attrs = %{
        name: "Initial Name",
        description: "Buy milk description 1",
        due_date: next_day
      }

      # Call context function and assert correct return
      assert {:ok, todo_id} = Todos.add_todo(attrs)

      aggregate_state = %Todo{
        todo_id: todo_id,
        name: "Initial Name",
        description: "Buy milk description 1",
        due_date: next_day
      }

      command = %RemoveTodo{todo_id: todo_id, removed_at: DateTime.utc_now()}

      assert {:ok, %TodoRemoved{todo_id: ^todo_id}} =
               RemoveTodoHandler.handle(aggregate_state, command)
    end
  end
end

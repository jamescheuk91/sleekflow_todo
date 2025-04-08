defmodule SleekFlowTodo.TodosTest do
  use SleekFlowTodo.DataCase, async: false

  alias SleekFlowTodo.Todos
  # alias SleekFlowTodo.Todos.Commands.AddTodo <- No longer needed directly
  alias SleekFlowTodo.Todos.Events.TodoAdded
  # alias SleekFlowTodo.CommandedApplication <- No longer needed directly

  test "ensure add_todo/1 publishes a TodoAdded event" do
    next_day = DateTime.add(DateTime.utc_now(), 1, :day)
    next_day_string = DateTime.to_iso8601(next_day)
    now = DateTime.utc_now()
    now_string = DateTime.to_iso8601(now)

    attrs = %{
      name: "buy milk",
      description: "Buy milk description",
      due_date: next_day_string,
      added_at: now_string
    }

    # Call context function and assert correct return
    assert {:ok, todo_id} = Todos.add_todo(attrs)

    # Increase timeout significantly
    assert_receive_event(SleekFlowTodo.CommandedApplication, TodoAdded, fn event ->
      # Assert todo_id from context matches event
      assert event.todo_id == todo_id
      assert event.name == "buy milk"
      assert event.description == "Buy milk description"
      assert event.due_date == next_day
      assert event.added_at == now
    end)
  end
end

defmodule SleekFlowTodo.Todos.Aggregates.TodoTest do
  use ExUnit.Case

  alias SleekFlowTodo.Todos.Aggregates.Todo
  alias SleekFlowTodo.Todos.Events.TodoAdded

  test "add_todo/6 returns TodoAdded event" do
    todo_id = Commanded.UUID.uuid4()
    next_day = DateTime.add(DateTime.utc_now(), 1, :day)
    now = DateTime.utc_now()

    assert %TodoAdded{} = event =
             Todo.add(%Todo{}, todo_id, "Buy milk", "Buy milk description", next_day, now)

    assert event.todo_id == todo_id
    assert event.name == "Buy milk"
    assert event.description == "Buy milk description"
    assert event.due_date == next_day
    assert event.added_at == now
    assert event.status == :not_started
  end

  test "apply/2 TodoAdded event to Todo aggregate" do
    todo_id = Commanded.UUID.uuid4()
    next_day = DateTime.add(DateTime.utc_now(), 1, :day)
    now = DateTime.utc_now()

    state = %Todo{}

    event = %TodoAdded{
      todo_id: todo_id,
      name: "Buy milk",
      description: "Buy milk description",
      due_date: next_day,
      added_at: now
    }

    assert %Todo{
             todo_id: ^todo_id,
             name: "Buy milk",
             description: "Buy milk description",
             due_date: ^next_day,
             added_at: ^now,
             status: :not_started
           } = Todo.apply(state, event)
  end
end

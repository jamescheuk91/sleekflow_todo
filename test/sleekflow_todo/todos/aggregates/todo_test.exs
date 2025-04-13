defmodule SleekFlowTodo.Todos.Aggregates.TodoTest do
  use ExUnit.Case

  alias SleekFlowTodo.Todos.Aggregates.Todo
  alias SleekFlowTodo.Todos.Events.TodoAdded
  alias SleekFlowTodo.Todos.Events.TodoEdited

  test "add_todo/6 returns TodoAdded event" do
    todo_id = Commanded.UUID.uuid4()
    next_day = DateTime.add(DateTime.utc_now(), 1, :day)
    priority = :high
    now = DateTime.utc_now()
    tags = ["tag1", "tag2"]

    assert %TodoAdded{} =
             event =
             Todo.add(
               %Todo{},
               todo_id,
               "Buy milk",
               "Buy milk description",
               next_day,
               priority,
               tags,
               now
             )

    assert event.todo_id == todo_id
    assert event.name == "Buy milk"
    assert event.description == "Buy milk description"
    assert event.due_date == next_day
    assert event.added_at == now
    assert event.status == :not_started
    assert event.tags == tags
    assert event.priority == priority
  end

  test "apply/2 TodoAdded event to Todo aggregate" do
    todo_id = Commanded.UUID.uuid4()
    next_day = DateTime.add(DateTime.utc_now(), 1, :day)
    now = DateTime.utc_now()
    tags = []

    state = %Todo{}

    event = %TodoAdded{
      todo_id: todo_id,
      name: "Buy milk",
      description: "Buy milk description",
      due_date: next_day,
      status: :not_started,
      tags: tags,
      added_at: now
    }

    assert %Todo{
             todo_id: ^todo_id,
             name: "Buy milk",
             description: "Buy milk description",
             due_date: ^next_day,
             status: :not_started,
             tags: ^tags,
             added_at: ^now,
             updated_at: nil,
             deleted: false
           } = Todo.apply(state, event)
  end

  test "apply/2 TodoEdited event to Todo aggregate" do
    todo_id = Commanded.UUID.uuid4()
    now = DateTime.utc_now()
    later = DateTime.add(now, 1, :hour)
    tomorrow = DateTime.add(now, 1, :day)

    initial_state = %Todo{
      todo_id: todo_id,
      name: "Initial Name",
      description: "Initial Description",
      due_date: tomorrow,
      status: :not_started,
      added_at: now,
      updated_at: nil
    }

    event = %TodoEdited{
      todo_id: todo_id,
      name: "Updated Name",
      description: "Updated Description",
      due_date: later,
      status: :in_progress
    }

    updated_state = Todo.apply(initial_state, event)

    assert updated_state.todo_id == todo_id
    assert updated_state.name == "Updated Name"
    assert updated_state.description == "Updated Description"
    assert updated_state.due_date == later
    assert updated_state.status == :in_progress
    assert updated_state.added_at == now
    assert !is_nil(updated_state.updated_at)
    assert DateTime.diff(DateTime.utc_now(), updated_state.updated_at) < 2
  end
end

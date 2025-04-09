defmodule SleekFlowTodo.Todos.Commands.AddTodoHandlerTest do
  use ExUnit.Case

  alias SleekFlowTodo.Todos.Aggregates.Todo
  alias SleekFlowTodo.Todos.Commands.AddTodo
  alias SleekFlowTodo.Todos.Commands.AddTodoHandler
  alias SleekFlowTodo.Todos.Events.TodoAdded

  test "handle/2 AddTodo command successfully" do
    todo_id = Commanded.UUID.uuid4()
    added_at_dt = DateTime.utc_now()
    next_day_dt = DateTime.add(added_at_dt, 1, :day)

    aggregate = %Todo{}

    command = %AddTodo{
      todo_id: todo_id,
      name: "Buy milk",
      description: "Buy milk description",
      due_date: next_day_dt,
      added_at: added_at_dt
    }

    assert {:ok, %TodoAdded{}} = AddTodoHandler.handle(aggregate, command)
  end

  test "handle/2 AddTodo command with minimal valid attributes" do
    todo_id = Commanded.UUID.uuid4()
    added_at_dt = DateTime.utc_now()

    aggregate = %Todo{}

    command = %AddTodo{
      todo_id: todo_id,
      name: "Buy milk",
      added_at: added_at_dt
    }

    assert {:ok, %TodoAdded{}} = AddTodoHandler.handle(aggregate, command)
  end

  test "handle/2 AddTodo command with nil description" do
    todo_id = Commanded.UUID.uuid4()
    added_at_dt = DateTime.utc_now()
    next_day_dt = DateTime.add(added_at_dt, 1, :day)

    aggregate = %Todo{}

    command = %AddTodo{
      todo_id: todo_id,
      name: "Buy milk",
      description: nil,
      due_date: next_day_dt,
      added_at: added_at_dt
    }

    assert {:ok, %TodoAdded{}} = AddTodoHandler.handle(aggregate, command)
  end

  test "handle/2 AddTodo command with nil due_date" do
    todo_id = Commanded.UUID.uuid4()
    added_at_dt = DateTime.utc_now()

    aggregate = %Todo{}

    command = %AddTodo{
      todo_id: todo_id,
      name: "Buy milk",
      description: "Get 2% milk from the store",
      due_date: nil,
      added_at: added_at_dt
    }

    assert {:ok, %TodoAdded{}} = AddTodoHandler.handle(aggregate, command)
  end

  test "handle/2 AddTodo command fails due to missing name" do
    todo_id = Commanded.UUID.uuid4()
    added_at_dt = DateTime.utc_now()
    aggregate = %Todo{}

    command = %AddTodo{
      todo_id: todo_id,
      name: nil,
      added_at: added_at_dt
    }

    assert {:error, {:name, "Name is required"}} = AddTodoHandler.handle(aggregate, command)
  end

  test "handle/2 AddTodo command fails due to invalid name" do
    todo_id = Commanded.UUID.uuid4()
    added_at_dt = DateTime.utc_now()
    next_day_dt = DateTime.add(added_at_dt, 1, :day)
    aggregate = %Todo{}

    command = %AddTodo{
      todo_id: todo_id,
      name: "a",
      description: "Buy milk description",
      due_date: next_day_dt,
      added_at: added_at_dt
    }

    assert {:error, {:name, "Name must be at least 2 characters"}} =
             AddTodoHandler.handle(aggregate, command)
  end

  test "handle/2 AddTodo command fails due to invalid description" do
    added_at_dt = DateTime.utc_now()

    command = %AddTodo{
      todo_id: Commanded.UUID.uuid4(),
      name: "buy some milk",
      description: "B",
      added_at: added_at_dt
    }

    aggregate = %Todo{}

    assert {:error, {:description, "Description must be at least 2 characters"}} =
             AddTodoHandler.handle(aggregate, command)
  end

  test "handle/2 AddTodo command fails due to invalid due_date" do
    todo_id = Commanded.UUID.uuid4()
    added_at_dt = DateTime.utc_now()
    past_date_dt = DateTime.add(added_at_dt, -1, :day)
    aggregate = %Todo{}

    command = %AddTodo{
      todo_id: todo_id,
      name: "Buy milk",
      description: "Buy milk description",
      due_date: past_date_dt,
      added_at: added_at_dt
    }

    assert {:error, {:due_date, "Due date must be in the future"}} =
             AddTodoHandler.handle(aggregate, command)
  end

  test "handle/2 AddTodo command fails due to invalid name and description" do
    added_at_dt = DateTime.utc_now()

    command = %AddTodo{
      todo_id: Commanded.UUID.uuid4(),
      name: "a",
      description: "B",
      added_at: added_at_dt
    }

    aggregate = %Todo{}

    assert {:error,
            [
              {:name, "Name must be at least 2 characters"},
              {:description, "Description must be at least 2 characters"}
            ]} = AddTodoHandler.handle(aggregate, command)
  end

  test "handle/2 AddTodo command fails due to invalid name, description and due_date" do
    todo_id = Commanded.UUID.uuid4()
    added_at_dt = DateTime.utc_now()
    past_date_dt = DateTime.add(added_at_dt, -1, :day)
    aggregate = %Todo{}

    command = %AddTodo{
      todo_id: todo_id,
      name: "a",
      description: "B",
      due_date: past_date_dt,
      added_at: added_at_dt
    }

    assert {:error,
            [
              {:name, "Name must be at least 2 characters"},
              {:description, "Description must be at least 2 characters"},
              {:due_date, "Due date must be in the future"}
            ]} = AddTodoHandler.handle(aggregate, command)
  end
end

defmodule SleekFlowTodo.Todos.Commands.EditTodoHandlerTest do
  use ExUnit.Case, async: true

  alias SleekFlowTodo.Todos.Commands.{EditTodo, EditTodoHandler}
  alias SleekFlowTodo.Todos.Aggregates.Todo
  alias SleekFlowTodo.Todos.Events.TodoEdited

  @valid_todo_id Commanded.UUID.uuid4()
  @initial_aggregate_state %Todo{
    todo_id: @valid_todo_id,
    name: "Initial Name",
    description: "Initial Description",
    due_date: DateTime.add(DateTime.utc_now(), 3600, :second),
    status: :not_started,
    added_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }

  describe "handle/2" do
    test "successfully edits a todo with all valid fields" do
      future_date = DateTime.add(DateTime.utc_now(), 7200, :second)

      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "Updated Name",
        description: "Updated Description",
        due_date: future_date,
        status: :in_progress
      }

      expected_event = %TodoEdited{
        todo_id: @valid_todo_id,
        name: "Updated Name",
        description: "Updated Description",
        due_date: future_date,
        status: :in_progress
      }

      assert {:ok, ^expected_event} = EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "successfully edits a todo with optional fields as nil" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "Only Name Updated",
        description: nil,
        due_date: nil,
        status: nil
      }

      expected_event = %TodoEdited{
        todo_id: @valid_todo_id,
        name: "Only Name Updated",
        description: nil,
        due_date: nil,
        status: nil
      }

      assert {:ok, ^expected_event} = EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "returns error for missing name" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: nil,
        description: "Description",
        due_date: nil,
        status: :not_started
      }

      assert {:error, {:name, "Name is required"}} =
               EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "returns error for short name" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "N",
        description: "Description",
        due_date: nil,
        status: :not_started
      }

      assert {:error, {:name, "Name must be at least 2 characters"}} =
               EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "returns error for short description (if provided)" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "Valid Name",
        description: "D",
        due_date: nil,
        status: :not_started
      }

      assert {:error, {:description, "Description must be at least 2 characters"}} =
               EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "returns error for past due date" do
      past_date = DateTime.add(DateTime.utc_now(), -3600, :second)

      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "Valid Name",
        description: "Valid Description",
        due_date: past_date,
        status: :not_started
      }

      assert {:error, {:due_date, "Due date must be in the future"}} =
               EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "returns error for invalid due date format" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "Valid Name",
        description: "Valid Description",
        due_date: "not-a-date",
        status: :not_started
      }

      assert {:error, {:due_date, "Invalid due date format"}} =
               EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "returns error for invalid status" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "Valid Name",
        description: "Valid Description",
        due_date: nil,
        status: :invalid_status
      }

      assert {:error, {:status, "Invalid status"}} =
               EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "returns multiple errors if multiple fields are invalid" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "N", # Invalid: too short
        description: nil,
        due_date: DateTime.add(DateTime.utc_now(), -100, :second), # Invalid: past date
        status: :wrong_status # Invalid: unknown status
      }

      expected_errors = [
        {:name, "Name must be at least 2 characters"},
        {:due_date, "Due date must be in the future"},
        {:status, "Invalid status"}
      ]

      assert {:error, ^expected_errors} = EditTodoHandler.handle(@initial_aggregate_state, command)
    end


  end
end

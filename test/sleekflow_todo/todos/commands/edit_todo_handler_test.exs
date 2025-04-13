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
    tags: ["initial"],
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
        status: :in_progress,
        tags: ["updated", "work"]
      }

      expected_event = %TodoEdited{
        todo_id: @valid_todo_id,
        name: "Updated Name",
        description: "Updated Description",
        due_date: future_date,
        status: :in_progress,
        tags: ["updated", "work"]
      }

      assert {:ok, event} = EditTodoHandler.handle(@initial_aggregate_state, command)
      assert event == expected_event
    end

    test "successfully edits a todo with optional fields as nil" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "Only Name Updated",
        description: nil,
        due_date: nil,
        status: nil,
        tags: nil
      }

      expected_event = %TodoEdited{
        todo_id: @valid_todo_id,
        name: "Only Name Updated",
        description: nil,
        due_date: nil,
        status: nil,
        tags: nil
      }

      assert {:ok, event} = EditTodoHandler.handle(@initial_aggregate_state, command)
      assert event == expected_event
    end

    test "returns error for missing name" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "",
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

    test "returns error for invalid tags (not a list, not nil)" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "Valid Name",
        tags: "not-a-list"
      }

      assert {:error, {:tags, "Tags must be a list of strings"}} ==
               EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "returns error for invalid tags (list contains non-string)" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "Valid Name",
        tags: ["valid", 123]
      }

      assert {:error, {:tags, "All tags must be strings"}} ==
               EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "successfully edits with empty tags list" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        tags: []
      }

      expected_event = %TodoEdited{
        todo_id: @valid_todo_id,
        name: nil,
        description: nil,
        due_date: nil,
        status: nil,
        tags: []
      }

      assert {:ok, event} = EditTodoHandler.handle(@initial_aggregate_state, command)
      assert event == expected_event
    end

    test "returns multiple errors including invalid tags" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        # Invalid: too short
        name: "N",
        description: nil,
        # Invalid: past date
        due_date: DateTime.add(DateTime.utc_now(), -100, :second),
        # Invalid: unknown status
        status: :wrong_status,
        # Invalid: not a list
        tags: "not-a-list"
      }

      expected_errors = [
        {:name, "Name must be at least 2 characters"},
        {:due_date, "Due date must be in the future"},
        {:status, "Invalid status"},
        {:tags, "Tags must be a list of strings"}
      ]

      assert {:error, errors} = EditTodoHandler.handle(@initial_aggregate_state, command)
      assert errors == expected_errors
    end

    # Priority Tests
    test "successfully edits priority to :low" do
      command = %EditTodo{todo_id: @valid_todo_id, priority: :low}
      expected_event = %TodoEdited{todo_id: @valid_todo_id, priority: :low}
      assert {:ok, event} = EditTodoHandler.handle(@initial_aggregate_state, command)
      # Check only the priority field in the event
      assert event.priority == expected_event.priority
    end

    test "successfully edits priority to :medium" do
      command = %EditTodo{todo_id: @valid_todo_id, priority: :medium}
      expected_event = %TodoEdited{todo_id: @valid_todo_id, priority: :medium}
      assert {:ok, event} = EditTodoHandler.handle(@initial_aggregate_state, command)
      assert event.priority == expected_event.priority
    end

    test "successfully edits priority to :high" do
      command = %EditTodo{todo_id: @valid_todo_id, priority: :high}
      expected_event = %TodoEdited{todo_id: @valid_todo_id, priority: :high}
      assert {:ok, event} = EditTodoHandler.handle(@initial_aggregate_state, command)
      assert event.priority == expected_event.priority
    end

    test "successfully edits with priority as nil (no change)" do
      command = %EditTodo{todo_id: @valid_todo_id, priority: nil}
      expected_event = %TodoEdited{todo_id: @valid_todo_id, priority: nil}
      assert {:ok, event} = EditTodoHandler.handle(@initial_aggregate_state, command)
      assert event.priority == expected_event.priority
    end

    test "returns error for invalid priority atom" do
      command = %EditTodo{todo_id: @valid_todo_id, priority: :urgent}
      expected_error = {:error, {:priority, "Priority must be one of: [:low, :medium, :high]"}}
      assert expected_error == EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "returns error for invalid priority type" do
      command = %EditTodo{todo_id: @valid_todo_id, priority: "medium"}
      expected_error = {:error, {:priority, "Priority must be one of: [:low, :medium, :high]"}}
      assert expected_error == EditTodoHandler.handle(@initial_aggregate_state, command)
    end

    test "returns multiple errors including invalid priority" do
      command = %EditTodo{
        todo_id: @valid_todo_id,
        name: "N", # Invalid
        priority: :invalid # Invalid
      }
      expected_errors = [
        {:name, "Name must be at least 2 characters"},
        {:priority, "Priority must be one of: [:low, :medium, :high]"}
      ]
      assert {:error, errors} = EditTodoHandler.handle(@initial_aggregate_state, command)
      assert errors == expected_errors
    end
  end
end

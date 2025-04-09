defmodule SleekFlowTodo.TodosTest do
  use SleekFlowTodo.DataCase, async: false

  alias SleekFlowTodo.Todos
  # alias SleekFlowTodo.Todos.Commands.AddTodo <- No longer needed directly
  alias SleekFlowTodo.Todos.Events.TodoAdded
  # alias SleekFlowTodo.CommandedApplication <- No longer needed directly
  describe "add_todo/1" do
    test "ensure add_todo/1 publishes a TodoAdded event" do
      next_day = DateTime.add(DateTime.utc_now(), 1, :day)

      attrs = %{
        name: "buy milk 1",
        description: "Buy milk description 1",
        due_date: next_day
      }

      # Call context function and assert correct return
      assert {:ok, todo_id} = Todos.add_todo(attrs)

      # Increase timeout significantly
      assert_receive_event(SleekFlowTodo.CommandedApplication, TodoAdded,
      fn event -> event.todo_id == todo_id end,
      fn event ->
        assert event.name == "buy milk 1"
        assert event.description == "Buy milk description 1"
        assert event.due_date == next_day
        assert event.added_at
      end)
    end

    test "returns an error when the command is invalid (name is too short)" do
      next_day = DateTime.add(DateTime.utc_now(), 1, :day)

      attrs = %{
        name: "b",
        due_date: next_day
      }

      assert {:error, error_details} = Todos.add_todo(attrs)
      assert error_details == {:name, "Name must be at least 2 characters"}
    end

    test "returns an error when the command is invalid (description is too short)" do
      next_day = DateTime.add(DateTime.utc_now(), 1, :day)

      attrs = %{
        name: "buy milk",
        description: "d",
        due_date: next_day
      }

      assert {:error, error_details} = Todos.add_todo(attrs)
      assert error_details == {:description, "Description must be at least 2 characters"}
    end

    test "returns an error when the due date is in the past" do
      yesterday = DateTime.add(DateTime.utc_now(), -1, :day)

      attrs = %{
        name: "buy milk",
        description: "Buy milk description",
        due_date: yesterday
      }

      assert {:error, error_details} = Todos.add_todo(attrs)
      assert error_details == {:due_date, "Due date must be in the future"}
    end

    test "returns an error when the command is invalid (due date is not a DateTime)" do
      attrs = %{
        name: "buy milk",
        description: "Buy milk description",
        due_date: "not a DateTime"
      }

      assert {:error, error_details} = Todos.add_todo(attrs)
      assert error_details == {:due_date, "Invalid due date format"}
    end

    test "returns a list of errors when multiple commands are invalid" do
      attrs = %{
        name: "b",
        description: "d",
        due_date: "not a DateTime"
      }

      assert {:error, error_details} = Todos.add_todo(attrs)
      assert error_details == [
        {:name, "Name must be at least 2 characters"},
        {:description, "Description must be at least 2 characters"},
        {:due_date, "Invalid due date format"}
      ]
    end
  end
end

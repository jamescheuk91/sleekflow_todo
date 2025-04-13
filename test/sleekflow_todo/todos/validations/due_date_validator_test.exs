defmodule SleekFlowTodo.Todos.Validations.DueDateValidatorTest do
  use ExUnit.Case, async: true

  alias SleekFlowTodo.Todos.Validations.DueDateValidator

  describe "validate_due_date_optional/1" do
    test "returns :ok when due_date is nil" do
      assert DueDateValidator.validate_due_date_optional(%{due_date: nil}) == :ok
    end

    test "returns :ok when due_date is a future DateTime" do
      future_date = DateTime.add(DateTime.utc_now(), 60, :second)
      assert DueDateValidator.validate_due_date_optional(%{due_date: future_date}) == :ok
    end

    test "returns error when due_date is a past DateTime" do
      past_date = DateTime.add(DateTime.utc_now(), -60, :second)

      assert DueDateValidator.validate_due_date_optional(%{due_date: past_date}) ==
               {:error, {:due_date, "Due date must be in the future"}}
    end

    test "returns error when due_date is not a DateTime struct" do
      assert DueDateValidator.validate_due_date_optional(%{due_date: "invalid_date"}) ==
               {:error, {:due_date, "Invalid due date format"}}

      assert DueDateValidator.validate_due_date_optional(%{due_date: ~D[2024-01-01]}) ==
                {:error, {:due_date, "Invalid due date format"}}
    end
  end
end

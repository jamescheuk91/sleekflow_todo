defmodule SleekFlowTodo.Todos.Validations.PriorityValidatorTest do
  use ExUnit.Case, async: true

  alias SleekFlowTodo.Todos.Validations.PriorityValidator

  describe "validate_priority_optional/1" do
    test "returns :ok when priority is nil" do
      assert :ok = PriorityValidator.validate_priority_optional(%{priority: nil})
    end

    test "returns :ok when priority is :low" do
      assert :ok = PriorityValidator.validate_priority_optional(%{priority: :low})
    end

    test "returns :ok when priority is :medium" do
      assert :ok = PriorityValidator.validate_priority_optional(%{priority: :medium})
    end

    test "returns :ok when priority is :high" do
      assert :ok = PriorityValidator.validate_priority_optional(%{priority: :high})
    end

    test "returns error when priority is invalid" do
      assert {:error, {:priority, _}} = PriorityValidator.validate_priority_optional(%{priority: :invalid})
    end

    test "returns error with correct message when priority is invalid" do
      assert {:error, {:priority, message}} = PriorityValidator.validate_priority_optional(%{priority: :invalid})
      assert message =~ "Priority must be one of: [:low, :medium, :high]"
    end
  end
end

defmodule SleekFlowTodo.Todos.Validations.StatusValidatorTest do
  use ExUnit.Case, async: true

  alias SleekFlowTodo.Todos.Validations.StatusValidator

  describe "validate_status_optional/1" do
    test "returns :ok when status is nil" do
      assert :ok = StatusValidator.validate_status_optional(%{status: nil})
    end

    test "returns :ok when status is :not_started" do
      assert :ok = StatusValidator.validate_status_optional(%{status: :not_started})
    end

    test "returns :ok when status is :in_progress" do
      assert :ok = StatusValidator.validate_status_optional(%{status: :in_progress})
    end

    test "returns :ok when status is :completed" do
      assert :ok = StatusValidator.validate_status_optional(%{status: :completed})
    end

    test "returns error tuple when status is invalid" do
      assert {:error, {:status, "Invalid status"}} =
        StatusValidator.validate_status_optional(%{status: :invalid_status})
    end

    test "returns error tuple when status is a string" do
      assert {:error, {:status, "Invalid status"}} =
        StatusValidator.validate_status_optional(%{status: "not_started"})
    end
  end
end

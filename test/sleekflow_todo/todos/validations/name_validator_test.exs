defmodule SleekFlowTodo.Todos.Validations.NameValidatorTest do
  use ExUnit.Case, async: true
  alias SleekFlowTodo.Todos.Validations.NameValidator

  describe "validate_name_required/1" do
    test "returns error when name is nil" do
      assert NameValidator.validate_name_required(%{name: nil}) ==
               {:error, {:name, "Name is required"}}
    end

    test "returns error when name is an empty string" do
      assert NameValidator.validate_name_required(%{name: ""}) ==
               {:error, {:name, "Name cannot be empty"}}
    end

    test "returns error when name is less than 2 characters" do
      assert NameValidator.validate_name_required(%{name: "a"}) ==
               {:error, {:name, "Name must be at least 2 characters"}}
    end

    test "returns :ok when name is valid" do
      assert NameValidator.validate_name_required(%{name: "Valid Name"}) == :ok
    end
  end

  describe "validate_name_optional/1" do
    test "returns :ok when name is nil" do
      assert NameValidator.validate_name_optional(%{name: nil}) == :ok
    end

    test "returns error when name is an empty string" do
      assert NameValidator.validate_name_optional(%{name: ""}) ==
               {:error, {:name, "Name cannot be empty"}}
    end

    test "returns error when name is less than 2 characters" do
      assert NameValidator.validate_name_optional(%{name: "a"}) ==
               {:error, {:name, "Name must be at least 2 characters"}}
    end

    test "returns :ok when name is valid" do
      assert NameValidator.validate_name_optional(%{name: "Valid Name"}) == :ok
    end
  end
end

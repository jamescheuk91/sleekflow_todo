defmodule SleekFlowTodo.Todos.Validations.DescriptionValidatorTest do
  use ExUnit.Case, async: true

  alias SleekFlowTodo.Todos.Validations.DescriptionValidator

  describe "validate_description_optional/1" do
    test "returns :ok when description is nil" do
      assert DescriptionValidator.validate_description_optional(%{description: nil}) == :ok
    end

    test "returns :ok when description is valid" do
      assert DescriptionValidator.validate_description_optional(%{description: "Valid description"}) == :ok
      assert DescriptionValidator.validate_description_optional(%{description: "Ok"}) == :ok
    end

    test "returns error when description is too short" do
      assert DescriptionValidator.validate_description_optional(%{description: ""}) ==
               {:error, {:description, "Description must be at least 2 characters"}}

      assert DescriptionValidator.validate_description_optional(%{description: "a"}) ==
               {:error, {:description, "Description must be at least 2 characters"}}
    end

    test "returns error when description is not a binary" do
      assert DescriptionValidator.validate_description_optional(%{description: 123}) ==
               {:error, {:description, "Description must be at least 2 characters"}}

      assert DescriptionValidator.validate_description_optional(%{description: :atom}) ==
                {:error, {:description, "Description must be at least 2 characters"}}
    end

    # Note: Elixir maps return nil if a key doesn't exist,
    # so the first clause of validate_description_optional handles this.
    # Explicitly testing map without the key behaves identically to %{description: nil}
    test "returns :ok when description key is missing" do
       assert DescriptionValidator.validate_description_optional(%{}) == :ok
    end

  end
end

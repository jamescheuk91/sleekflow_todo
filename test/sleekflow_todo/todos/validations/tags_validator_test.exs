defmodule SleekFlowTodo.Todos.Validations.TagsValidatorTest do
  use ExUnit.Case, async: true

  alias SleekFlowTodo.Todos.Validations.TagsValidator

  describe "validate_tags_required_list/1" do
    test "returns :ok when tags is a list of strings" do
      assert :ok = TagsValidator.validate_tags_required_list(%{tags: ["work", "urgent"]})
    end

    test "returns error tuple when tags is a list containing non-string values" do
      assert {:error, {:tags, "All tags must be strings"}} =
        TagsValidator.validate_tags_required_list(%{tags: ["work", 123]})
    end

    test "returns error tuple when tags is not a list" do
      assert {:error, {:tags, "Tags must be a list of strings"}} =
        TagsValidator.validate_tags_required_list(%{tags: "work"})
    end
  end

  describe "validate_tags_optional_list/1" do
    test "returns :ok when tags is nil" do
      assert :ok = TagsValidator.validate_tags_optional_list(%{tags: nil})
    end

    test "returns :ok when tags is a list of strings" do
      assert :ok = TagsValidator.validate_tags_optional_list(%{tags: ["work", "urgent"]})
    end

    test "returns error tuple when tags is a list containing non-string values" do
      assert {:error, {:tags, "All tags must be strings"}} =
        TagsValidator.validate_tags_optional_list(%{tags: ["work", 123]})
    end

    test "returns error tuple when tags is not a list" do
      assert {:error, {:tags, "Tags must be a list of strings"}} =
        TagsValidator.validate_tags_optional_list(%{tags: "work"})
    end
  end
end

defmodule SleekFlowTodo.Todos.Validations.TagsValidator do
  @moduledoc """
  Validation logic for the 'tags' field.
  """

  def validate_tags_required_list(%{tags: tags}), do: validate_tags_list_format(tags)
  def validate_tags_optional_list(%{tags: nil}), do: :ok
  def validate_tags_optional_list(%{tags: tags}), do: validate_tags_list_format(tags)

  defp validate_tags_list_format(tags) do
    cond do
      is_list(tags) and Enum.all?(tags, &is_binary/1) ->
        :ok
      is_list(tags) ->
        {:error, {:tags, "All tags must be strings"}}
      true ->
        {:error, {:tags, "Tags must be a list of strings"}}
    end
  end
end

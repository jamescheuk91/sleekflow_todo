defmodule SleekFlowTodo.Todos.Validations.DescriptionValidator do
  @moduledoc """
  Validation logic for the 'description' field.
  """

  def validate_description_optional(params) do
    case Map.get(params, :description) do
      nil ->
        :ok

      description ->
        validate_description_format(description)
    end
  end

  defp validate_description_format(description) do
    if is_binary(description) and String.length(description) >= 2 do
      :ok
    else
      {:error, {:description, "Description must be at least 2 characters"}}
    end
  end
end

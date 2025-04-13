defmodule SleekFlowTodo.Todos.Validations.NameValidator do
  @moduledoc """
  Validation logic for the 'name' field.
  """

  def validate_name_required(%{name: nil}), do: {:error, {:name, "Name is required"}}
  def validate_name_required(%{name: name}), do: validate_name_format(name)

  def validate_name_optional(%{name: nil}), do: :ok
  def validate_name_optional(%{name: name}), do: validate_name_format(name)

  defp validate_name_format(name) do
    cond do
      # Explicitly disallow empty string ""
      name == "" ->
        {:error, {:name, "Name cannot be empty"}}

      is_binary(name) and String.length(name) >= 2 ->
        :ok

      true ->
        {:error, {:name, "Name must be at least 2 characters"}}
    end
  end
end

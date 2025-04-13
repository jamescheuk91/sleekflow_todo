defmodule SleekFlowTodo.Todos.Validations.StatusValidator do
  @moduledoc """
  Validation logic for the 'status' field.
  """

  def validate_status_optional(%{status: nil}), do: :ok

  def validate_status_optional(%{status: status}) do
    if status in [:not_started, :in_progress, :completed] do
      :ok
    else
      {:error, {:status, "Invalid status"}}
    end
  end
end

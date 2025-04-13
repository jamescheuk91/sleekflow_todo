defmodule SleekFlowTodo.Todos.Validations.DueDateValidator do
  @moduledoc """
  Validation logic for the 'due_date' field.
  """

  def validate_due_date_optional(%{due_date: nil}), do: :ok
  def validate_due_date_optional(%{due_date: due_date}), do: validate_due_date_format(due_date)

  defp validate_due_date_format(due_date) do
    if is_struct(due_date, DateTime) do
      now = DateTime.utc_now()
      case DateTime.compare(due_date, now) do
        :gt -> :ok
        _    -> {:error, {:due_date, "Due date must be in the future"}}
      end
    else
      {:error, {:due_date, "Invalid due date format"}}
    end
  end
end

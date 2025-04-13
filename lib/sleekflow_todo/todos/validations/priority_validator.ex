defmodule SleekFlowTodo.Todos.Validations.PriorityValidator do
  @moduledoc """
  Validation logic for the 'priority' field.
  """

  def validate_priority_optional(%{priority: nil}), do: :ok
  def validate_priority_optional(%{priority: priority}), do: validate_priority_format(priority)

  defp validate_priority_format(priority) do
    allowed_priorities = [:low, :medium, :high]
    if Enum.member?(allowed_priorities, priority) do
      :ok
    else
      {:error, {:priority, "Priority must be one of: #{inspect(allowed_priorities)}"}}
    end
  end
end

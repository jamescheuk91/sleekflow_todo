defmodule SleekFlowTodo.Todos.Commands.EditTodoHandler do
  @moduledoc """
  Handler for the EditTodo command.
  """

  require Logger

  alias SleekFlowTodo.Todos.Commands.EditTodo
  alias SleekFlowTodo.Todos.Aggregates.Todo

  def handle(aggregate, command) do
    Logger.debug("[EditTodoHandler] Received aggregate: #{inspect(aggregate)}")
    Logger.debug("[EditTodoHandler] Received command: #{inspect(command)}")

    validators = [
      &validate_name/1,
      &validate_description/1,
      &validate_due_date/1,
      &validate_status/1,
      &validate_tags/1,
      &validate_priority/1
    ]

    case validate(command, validators) do
      :ok ->
        %EditTodo{
          todo_id: todo_id,
          name: name,
          description: description,
          due_date: due_date,
          status: status,
          priority: priority,
          tags: tags
        } = command

        result = Todo.edit(aggregate, todo_id, name, description, due_date, status, priority, tags)
        {:ok, result}

      {:error, error_details} ->
        {:error, error_details}
    end
  end

  # Generic validation function
  defp validate(params, validators) do
    errors =
      Enum.reduce(validators, [], fn validator, acc ->
        case validator.(params) do
          :ok ->
            acc

          {:error, reason} ->
            [reason | acc]
        end
      end)

    cond do
      Enum.empty?(errors) ->
        :ok

      length(errors) == 1 ->
        # Return the single error tuple directly
        {:error, hd(errors)}

      true ->
        # Reverse the list to maintain the order of validation checks for multiple errors
        {:error, Enum.reverse(errors)}
    end
  end

  # Individual validators (now take the whole command)
  # Allow nil name during edit, only validate if provided
  defp validate_name(%EditTodo{name: nil}), do: :ok

  defp validate_name(%EditTodo{name: name}) do
    # Check if name is an empty/short string *only if it's not nil*
    cond do
      # Simplified check, as nil is handled above
      name == "" ->
        {:error, {:name, "Name is required"}}

      is_binary(name) and String.length(name) >= 2 ->
        :ok

      true ->
        {:error, {:name, "Name must be at least 2 characters"}}
    end
  end

  # Allow nil
  defp validate_description(%EditTodo{description: nil}), do: :ok

  defp validate_description(%EditTodo{description: description}) do
    if is_binary(description) and String.length(description) >= 2 do
      :ok
    else
      {:error, {:description, "Description must be at least 2 characters"}}
    end
  end

  # Allow nil
  defp validate_due_date(%EditTodo{due_date: nil}), do: :ok

  defp validate_due_date(%EditTodo{due_date: due_date}) do
    if is_struct(due_date, DateTime) do
      now = DateTime.utc_now()

      case DateTime.compare(due_date, now) do
        :gt -> :ok
        _ -> {:error, {:due_date, "Due date must be in the future"}}
      end
    else
      # Handle cases where due_date is not a DateTime struct
      {:error, {:due_date, "Invalid due date format"}}
    end
  end

  defp validate_status(%EditTodo{status: nil}), do: :ok

  defp validate_status(%EditTodo{status: status}) do
    if status in [:not_started, :in_progress, :completed] do
      :ok
    else
      {:error, {:status, "Invalid status"}}
    end
  end

  # Validate tags - allow nil, otherwise must be list of strings
  defp validate_tags(%EditTodo{tags: nil}), do: :ok

  defp validate_tags(%EditTodo{tags: tags}) do
    cond do
      is_list(tags) and Enum.all?(tags, &is_binary/1) ->
        :ok

      is_list(tags) ->
        {:error, {:tags, "All tags must be strings"}}

      true ->
        {:error, {:tags, "Tags must be a list of strings"}}
    end
  end

  # Validate priority - allow nil, otherwise must be low, medium or high
  defp validate_priority(%EditTodo{priority: nil}), do: :ok

  defp validate_priority(%EditTodo{priority: priority}) do
    allowed_priorities = [:low, :medium, :high]
    if Enum.member?(allowed_priorities, priority) do
      :ok
    else
      {:error, {:priority, "Priority must be one of: #{inspect(allowed_priorities)}"}}
    end
  end
end

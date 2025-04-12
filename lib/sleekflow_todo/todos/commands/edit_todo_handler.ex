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
      &validate_status/1
    ]

    case validate(command, validators) do
      :ok ->
        %EditTodo{
          todo_id: todo_id,
          name: name,
          description: description,
          due_date: due_date,
          status: status
        } = command

        result = Todo.edit(aggregate, todo_id, name, description, due_date, status)
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
  defp validate_name(%EditTodo{name: name}) do
    # Check if name is nil or an empty/short string
    cond do
      is_nil(name) or name == "" ->
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
end

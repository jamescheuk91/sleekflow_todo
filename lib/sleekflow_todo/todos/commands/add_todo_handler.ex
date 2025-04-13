defmodule SleekFlowTodo.Todos.Commands.AddTodoHandler do
  @behaviour Commanded.Commands.Handler
  @moduledoc """
  Handler for the AddTodo command.
  """
  require Logger

  alias SleekFlowTodo.Todos.Commands.AddTodo
  alias SleekFlowTodo.Todos.Aggregates.Todo

  def handle(aggregate, command) do
    Logger.debug("[AddTodoHandler] Received aggregate: #{inspect(aggregate)}")
    Logger.debug("[AddTodoHandler] Received command: #{inspect(command)}")

    validators = [
      &validate_name/1,
      &validate_description/1,
      &validate_due_date/1,
      &validate_tags/1,
      &validate_priority/1
    ]

    case validate(command, validators) do
      :ok ->
        %AddTodo{
          todo_id: todo_id,
          name: name,
          description: description,
          due_date: due_date,
          priority: priority,
          tags: tags,
          added_at: added_at
        } = command

        result = Todo.add(aggregate, todo_id, name, description, due_date, priority, tags, added_at)
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
  defp validate_name(%AddTodo{name: nil}), do: {:error, {:name, "Name is required"}}

  defp validate_name(%AddTodo{name: name}) do
    if is_binary(name) and String.length(name) >= 2 do
      :ok
    else
      {:error, {:name, "Name must be at least 2 characters"}}
    end
  end

  # Allow nil
  defp validate_description(%AddTodo{description: nil}), do: :ok

  defp validate_description(%AddTodo{description: description}) do
    if is_binary(description) and String.length(description) >= 2 do
      :ok
    else
      {:error, {:description, "Description must be at least 2 characters"}}
    end
  end

  # Allow nil
  defp validate_due_date(%AddTodo{due_date: nil}), do: :ok

  defp validate_due_date(%AddTodo{due_date: due_date}) do
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

  # Validate tags - must be a list of strings
  defp validate_tags(%AddTodo{tags: tags}) do
    cond do
      is_list(tags) and Enum.all?(tags, &is_binary/1) ->
        :ok

      is_list(tags) ->
        {:error, {:tags, "All tags must be strings"}}

      true ->
        {:error, {:tags, "Tags must be a list of strings"}}
    end
  end

  # Allow nil priority
  defp validate_priority(%AddTodo{priority: nil}), do: :ok

  defp validate_priority(%AddTodo{priority: priority}) do
    allowed_priorities = [:low, :medium, :high]
    if Enum.member?(allowed_priorities, priority) do
      :ok
    else
      {:error, {:priority, "Priority must be one of: #{inspect(allowed_priorities)}"}}
    end
  end
end

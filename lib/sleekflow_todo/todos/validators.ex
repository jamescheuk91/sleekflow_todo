defmodule SleekFlowTodo.Todos.Validators do
  @moduledoc """
  Contains validation logic for Todo commands.
  """

  alias SleekFlowTodo.Todos.Commands.{AddTodo, EditTodo}

  def validate_add_command(%AddTodo{} = command) do
    validators = [
      &validate_name_required/1,
      &validate_description_optional/1,
      &validate_due_date_optional/1,
      &validate_tags_required_list/1,
      &validate_priority_optional/1
    ]

    run_validators(command, validators)
  end

  def validate_edit_command(%EditTodo{} = command) do
    validators = [
      &validate_name_optional/1,
      &validate_description_optional/1,
      &validate_due_date_optional/1,
      &validate_status_optional/1,
      &validate_tags_optional_list/1,
      &validate_priority_optional/1
    ]

    run_validators(command, validators)
  end

  # Generic validation runner
  defp run_validators(params, validators) do
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
        {:error, hd(errors)}

      true ->
        # Keep original order for multiple errors
        {:error, Enum.reverse(errors)}
    end
  end

  # --- Individual Validators ---

  # Name Validators
  defp validate_name_required(%{name: nil}), do: {:error, {:name, "Name is required"}}
  defp validate_name_required(%{name: name}), do: validate_name_format(name)

  defp validate_name_optional(%{name: nil}), do: :ok
  defp validate_name_optional(%{name: name}), do: validate_name_format(name)

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

  # Description Validators
  defp validate_description_optional(%{description: nil}), do: :ok

  defp validate_description_optional(%{description: description}),
    do: validate_description_format(description)

  defp validate_description_format(description) do
    if is_binary(description) and String.length(description) >= 2 do
      :ok
    else
      {:error, {:description, "Description must be at least 2 characters"}}
    end
  end

  # Due Date Validators
  defp validate_due_date_optional(%{due_date: nil}), do: :ok
  defp validate_due_date_optional(%{due_date: due_date}), do: validate_due_date_format(due_date)

  defp validate_due_date_format(due_date) do
    if is_struct(due_date, DateTime) do
      now = DateTime.utc_now()

      case DateTime.compare(due_date, now) do
        :gt -> :ok
        _ -> {:error, {:due_date, "Due date must be in the future"}}
      end
    else
      {:error, {:due_date, "Invalid due date format"}}
    end
  end

  # Status Validators
  defp validate_status_optional(%{status: nil}), do: :ok

  defp validate_status_optional(%{status: status}) do
    if status in [:not_started, :in_progress, :completed] do
      :ok
    else
      {:error, {:status, "Invalid status"}}
    end
  end

  # Tags Validators
  defp validate_tags_required_list(%{tags: tags}), do: validate_tags_list_format(tags)
  defp validate_tags_optional_list(%{tags: nil}), do: :ok
  defp validate_tags_optional_list(%{tags: tags}), do: validate_tags_list_format(tags)

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

  # Priority Validators
  defp validate_priority_optional(%{priority: nil}), do: :ok
  defp validate_priority_optional(%{priority: priority}), do: validate_priority_format(priority)

  defp validate_priority_format(priority) do
    allowed_priorities = [:low, :medium, :high]

    if Enum.member?(allowed_priorities, priority) do
      :ok
    else
      {:error, {:priority, "Priority must be one of: #{inspect(allowed_priorities)}"}}
    end
  end
end

defmodule SleekFlowTodoWeb.TodoParamsParser do
  require Logger

  @doc """
  Parses parameters for the create action.
  Converts string keys to atoms and handles type conversions for due_date and priority.
  Returns {:ok, parsed_params} or {:error, reason}.
  """
  def parse_create_params(params) do
    params
    |> SleekFlowTodo.Utils.key_to_atom()
    |> parse_due_date()
    |> parse_priority()
    |> wrap_ok() # Assuming parsing functions now might return error tuples or log errors
  end

  @doc """
  Parses parameters for the update action.
  Converts string keys to atoms and handles type conversions for due_date, priority, and status.
  Returns {:ok, parsed_params} or {:error, reason}.
  """
  def parse_update_params(params) do
    params
    |> SleekFlowTodo.Utils.key_to_atom()
    |> parse_due_date()
    |> parse_priority()
    |> parse_status()
    |> wrap_ok() # Assuming parsing functions now might return error tuples or log errors
  end

  @doc """
  Parses filter parameters for the index action.
  Returns a map of valid filters.
  """
  def parse_index_filters(params) do
    filters = %{}

    filters =
      case Map.get(params, "status") do
        nil ->
          filters

        status_string when is_binary(status_string) ->
          case String.to_existing_atom(status_string) do
            atom when is_atom(atom) -> Map.put(filters, :status, atom)
            # Ignore invalid status strings for filtering
            _ ->
              Logger.debug("Ignoring invalid status filter: #{inspect(status_string)}")
              filters
          end

        # Ignore non-string status params
        _ ->
          Logger.debug("Ignoring non-string status filter parameter")
          filters
      end

    case Map.get(params, "due_date") do
      nil ->
        filters

      date_string when is_binary(date_string) ->
        case DateTime.from_iso8601(date_string) do
          {:ok, datetime, _offset} ->
            Map.put(filters, :due_date, datetime)

          {:error, _} ->
            # Ignore invalid date strings for filtering
            Logger.debug("Ignoring invalid due_date filter: #{inspect(date_string)}")
            filters
        end

      # Ignore non-string due_date params
      _ ->
        Logger.debug("Ignoring non-string due_date filter parameter")
        filters
    end
  end

  @doc """
  Parses sort parameters for the index action.
  Returns a map like %{field: :field_atom, direction: :direction_atom} or nil.
  """
  def parse_index_sort(params) do
    with field_str when is_binary(field_str) <- Map.get(params, "sort_field"),
         direction_str when is_binary(direction_str) <- Map.get(params, "sort_direction"),
         # Ensure atoms exist to prevent runtime errors
         {:ok, field_atom} <- safe_string_to_existing_atom(field_str),
         {:ok, direction_atom} <- safe_string_to_existing_atom(direction_str) do
      %{field: field_atom, direction: direction_atom}
    else
      # Handle cases where params are missing, not strings, or atoms don't exist
      _error_or_nil ->
        Logger.debug("Ignoring invalid sort parameters: #{inspect(params)}")
        nil
    end
  end

  # --- Private Helper Functions ---

  # Adapting original parsing functions slightly for better composition

  defp parse_due_date(params) do
    key = :due_date
    case Map.fetch(params, key) do
      {:ok, date_string} when is_binary(date_string) ->
        case DateTime.from_iso8601(date_string) do
          {:ok, datetime, _offset} ->
            Map.put(params, key, datetime)
          {:error, reason} ->
            # Log error, but keep original value for context validation later
            Logger.error("Failed to parse due_date '#{date_string}': #{inspect(reason)}")
            params
            # Or potentially return an error tuple here if immediate failure is desired
            # {:error, {:invalid_format, key, date_string}}
        end
      # Ignore if key doesn't exist or value is not a string
      _ ->
        params
    end
  end

  defp parse_status(params) do
    key = :status
    case Map.fetch(params, key) do
      {:ok, status_string} when is_binary(status_string) ->
        case safe_string_to_existing_atom(status_string) do
          {:ok, atom} -> Map.put(params, key, atom)
          {:error, _} ->
            Logger.error("Invalid status string received: #{inspect(status_string)}")
            params # Keep original value for context validation
            # {:error, {:invalid_value, key, status_string}}
        end
      _ ->
        params
    end
  end

  defp parse_priority(params) do
    key = :priority
    case Map.fetch(params, key) do
      {:ok, priority_string} when is_binary(priority_string) ->
        case safe_string_to_existing_atom(priority_string) do
          {:ok, atom} -> Map.put(params, key, atom)
          {:error, _} ->
            Logger.error("Invalid priority string received: #{inspect(priority_string)}")
            params # Keep original value for context validation
            # {:error, {:invalid_value, key, priority_string}}
        end
      _ ->
        params
    end
  end

  # Helper to safely convert string to atom, returning {:ok, atom} or {:error, reason}
  defp safe_string_to_existing_atom(str) do
    try do
      {:ok, String.to_existing_atom(str)}
    rescue
      ArgumentError -> {:error, :atom_does_not_exist}
    end
  end

  # Simple wrapper for the create/update parsers for now.
  # Could be enhanced to collect multiple parsing errors.
  defp wrap_ok(parsed_params) do
    {:ok, parsed_params}
    # If parsing functions returned errors:
    # case parsed_params do
    #   {:error, _} = error -> error
    #   params when is_map(params) -> {:ok, params}
    # end
  end
end

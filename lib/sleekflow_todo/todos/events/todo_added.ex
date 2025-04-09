defmodule SleekFlowTodo.Todos.Events.TodoAdded do
  @moduledoc """
  Event dispatched when a new todo item has been added.
  """
  @derive Jason.Encoder
  defstruct [:todo_id, :name, :description, :status, :due_date, :added_at]

  @type t :: %__MODULE__{
          todo_id: String.t(),
          name: String.t(),
          description: String.t(),
          status: :not_started | :in_progress | :completed,
          due_date: DateTime.t(),
          added_at: DateTime.t()
        }
end

defimpl Commanded.Serialization.JsonDecoder, for: SleekFlowTodo.Todos.Events.TodoAdded do
  @doc """
  Decode date strings into DateTime structs after JSON deserialization.
  Handles optional due_date.
  """
  def decode(
        %SleekFlowTodo.Todos.Events.TodoAdded{due_date: due_date, added_at: added_at} = event
      ) do
    parsed_added_at =
      if is_binary(added_at) do
        case DateTime.from_iso8601(added_at) do
          {:ok, dt, _} -> dt
          # Keep original if parsing fails
          _ -> added_at
        end
      else
        # Keep original if not a string
        added_at
      end

    parsed_due_date =
      cond do
        is_binary(due_date) ->
          case DateTime.from_iso8601(due_date) do
            {:ok, dt, _} -> dt
            # Keep original string if parsing fails
            _ -> due_date
          end

        is_nil(due_date) ->
          # Keep nil if it was nil
          nil

        true ->
          # Keep original if it's neither string nor nil
          due_date
      end

    # Return event with potentially updated fields
    %SleekFlowTodo.Todos.Events.TodoAdded{
      event
      | due_date: parsed_due_date,
        added_at: parsed_added_at
    }
  end
end

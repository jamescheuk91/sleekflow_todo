defmodule SleekFlowTodo.Todos.Events.TodoEdited do
  @moduledoc """
  Event dispatched when a todo item has been edited.
  """
  @derive Jason.Encoder
  defstruct [
    :todo_id,
    :name,
    :description,
    :due_date,
    :status
  ]

  @type t :: %__MODULE__{
          todo_id: String.t(),
          name: String.t(),
          description: String.t(),
          due_date: DateTime.t(),
          status: :not_started | :in_progress | :completed
        }
end

defimpl Commanded.Serialization.JsonDecoder, for: SleekFlowTodo.Todos.Events.TodoEdited do
  @doc """
  Decode date strings into DateTime structs after JSON deserialization.
  Handles optional due_date.
  """
  def decode(%SleekFlowTodo.Todos.Events.TodoEdited{due_date: due_date} = event) do
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
    %SleekFlowTodo.Todos.Events.TodoEdited{
      event
      | due_date: parsed_due_date
    }
  end
end

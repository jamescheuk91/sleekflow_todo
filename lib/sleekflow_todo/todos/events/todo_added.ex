defmodule SleekFlowTodo.Todos.Events.TodoAdded do
  @moduledoc """
  Event dispatched when a new todo item has been added.
  """
  @derive Jason.Encoder
  defstruct [:todo_id, :name, :description, :due_date, :added_at]

  @type t :: %__MODULE__{
          todo_id: String.t(),
          name: String.t(),
          description: String.t(),
          due_date: DateTime.t(),
          added_at: DateTime.t()
        }
end

defimpl Commanded.Serialization.JsonDecoder, for: SleekFlowTodo.Todos.Events.TodoAdded do
  @doc """
  Decode date strings into DateTime structs after JSON deserialization.
  """
  def decode(%SleekFlowTodo.Todos.Events.TodoAdded{due_date: due_date, added_at: added_at} = event) do
    # Ensure fields are strings before parsing
    if is_binary(due_date) and is_binary(added_at) do
      with {:ok, parsed_due_date, _} <- DateTime.from_iso8601(due_date),
           {:ok, parsed_added_at, _} <- DateTime.from_iso8601(added_at) do
        %SleekFlowTodo.Todos.Events.TodoAdded{event | due_date: parsed_due_date, added_at: parsed_added_at}
      else
        # Return the original event if parsing fails for some reason
        _error -> event
      end
    else
      # Return the original event if fields are not strings (e.g., already decoded)
      event
    end
  end
end

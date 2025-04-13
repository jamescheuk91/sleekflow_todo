defmodule SleekFlowTodo.Todos.Events.TodoEdited do
  @moduledoc """
  Event dispatched when a todo item has been edited.
  """
  @derive Jason.Encoder
  use TypedStruct

  typedstruct do
    @typedoc "An event indicating a todo item has been edited."
    field :todo_id, String.t(), enforce: true
    field :name, String.t()
    field :description, String.t()
    field :due_date, DateTime.t()
    field :status, Ecto.Enum, values: [:not_started, :in_progress, :completed]
    field :priority, atom()
    field :tags, list(String.t())
  end
end

defimpl Commanded.Serialization.JsonDecoder, for: SleekFlowTodo.Todos.Events.TodoEdited do
  @doc """
  Decode date strings into DateTime structs after JSON deserialization.
  Handles optional due_date.
  """
  def decode(
        %SleekFlowTodo.Todos.Events.TodoEdited{
          due_date: due_date,
          status: status,
          priority: priority
        } = event
      ) do
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

    parsed_status =
      if is_binary(status) do
        try do
          String.to_existing_atom(status)
        rescue
          # Keep original if not an existing atom
          ArgumentError -> status
        end
      else
        # Keep original if not a string
        status
      end

    parsed_priority =
      cond do
        is_binary(priority) ->
          try do
            String.to_existing_atom(priority)
          rescue
            # Keep original if not an existing atom
            ArgumentError -> priority
          end

        is_nil(priority) ->
          # Keep nil
          nil

        true ->
          # Keep original otherwise
          priority
      end

    # Return event with potentially updated fields
    %SleekFlowTodo.Todos.Events.TodoEdited{
      event
      | due_date: parsed_due_date,
        status: parsed_status,
        priority: parsed_priority
    }
  end
end

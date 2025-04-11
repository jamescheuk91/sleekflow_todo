defmodule SleekFlowTodo.Todos.Aggregates.Todo do
  @moduledoc """
  Aggregate responsible for handling a single Todo item.
  """
  require Logger

  alias SleekFlowTodo.Todos.Aggregates.Todo
  alias SleekFlowTodo.Todos.Events.TodoAdded
  alias SleekFlowTodo.Todos.Events.TodoEdited

  defstruct [
    :todo_id,
    :name,
    :description,
    :due_date,
    :status,
    :added_at,
    :updated_at,
    :completed_at
  ]

  @type t :: %__MODULE__{
          todo_id: String.t() | nil,
          name: String.t() | nil,
          description: String.t() | nil,
          due_date: DateTime.t() | nil,
          status: :not_started | :in_progress | :completed,
          added_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil,
          completed_at: DateTime.t() | nil
        }

  def add(%Todo{todo_id: nil} = aggregate_state, todo_id, name, description, due_date, added_at) do
    Logger.debug("[Todo.add] Received aggregate state: #{inspect(aggregate_state)}")

    Logger.debug(
      "[Todo.add] Params: todo_id=#{todo_id}, name=#{name}, description=#{description}, due_date=#{inspect(due_date)}, added_at=#{inspect(added_at)}"
    )

    event = %TodoAdded{
      todo_id: todo_id,
      name: name,
      description: description,
      status: :not_started,
      due_date: due_date,
      added_at: added_at
    }

    Logger.debug("[Todo.add] Returning event: #{inspect(event)}")

    event
  end

  def edit(
        %Todo{todo_id: todo_id} = aggregate_state,
        todo_id,
        name,
        description,
        due_date,
        status
      ) do
    Logger.debug("[Todo.edit] Received aggregate state: #{inspect(aggregate_state)}")
    Logger.debug("
    [Todo.edit] Pmaras:
    todo_id: #{todo_id}, name: #{name}, description: #{description}, due_date: #{inspect(due_date)}, status: #{status}
    ")

    event = %TodoEdited{
      todo_id: todo_id,
      name: name,
      description: description,
      due_date: due_date,
      status: status
    }
    Logger.debug("[Todo.edit] Returning event: #{inspect(event)}")

    event
  end

  # Event application
  def apply(%__MODULE__{} = state, %TodoAdded{} = event) do
    Logger.debug("[Todo.apply] Applying event: #{inspect(event)}")

    %__MODULE__{
      state
      | todo_id: event.todo_id,
        name: event.name,
        description: event.description,
        due_date: event.due_date,
        added_at: event.added_at,
        status: :not_started
    }
  end

  # Add apply function for TodoEdited
  def apply(%__MODULE__{} = state, %TodoEdited{} = event) do
    Logger.debug("[Todo.apply(TodoEdited)] Applying event: #{inspect(event)}")

    %__MODULE__{
      state
      | name: event.name,
        description: event.description,
        due_date: event.due_date,
        status: event.status,
        updated_at: DateTime.utc_now()
    }
  end
end

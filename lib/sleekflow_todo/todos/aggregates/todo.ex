defmodule SleekFlowTodo.Todos.Aggregates.Todo do
  @moduledoc """
  Aggregate responsible for handling a single Todo item.
  """
  require Logger

  alias SleekFlowTodo.Todos.Aggregates.Todo
  alias SleekFlowTodo.Todos.Events.TodoAdded
  alias SleekFlowTodo.Todos.Events.TodoEdited
  alias SleekFlowTodo.Todos.Events.TodoRemoved

  defstruct [
    :todo_id,
    :name,
    :description,
    :due_date,
    :status,
    :added_at,
    :updated_at,
    :completed_at,
    deleted: false
  ]

  @type t :: %__MODULE__{
          todo_id: String.t() | nil,
          name: String.t() | nil,
          description: String.t() | nil,
          due_date: DateTime.t() | nil,
          status: :not_started | :in_progress | :completed,
          added_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil,
          completed_at: DateTime.t() | nil,
          deleted: boolean()
        }

  def add(%Todo{todo_id: nil, deleted: false} = _aggregate_state, todo_id, name, description, due_date, added_at) do
    Logger.debug("[Todo.add] Params: todo_id=#{todo_id}, name=#{name}, description=#{description}, due_date=#{inspect(due_date)}, added_at=#{inspect(added_at)}")

    %TodoAdded{
      todo_id: todo_id,
      name: name,
      description: description,
      status: :not_started,
      due_date: due_date,
      added_at: added_at
    }
  end

  def edit(
        %Todo{todo_id: todo_id, deleted: false} = _aggregate_state,
        todo_id,
        name,
        description,
        due_date,
        status
      ) do
    Logger.debug("[Todo.edit] Params: todo_id: #{todo_id}, name: #{name}, description: #{description}, due_date: #{inspect(due_date)}, status: #{status}")

    %TodoEdited{
      todo_id: todo_id,
      name: name,
      description: description,
      due_date: due_date,
      status: status
    }
  end

  def remove(%Todo{todo_id: todo_id, deleted: false} = _aggregate_state, todo_id, removed_at) do
    Logger.debug("[Todo.remove] Params: todo_id: #{todo_id}, removed_at: #{inspect(removed_at)}")
    %TodoRemoved{todo_id: todo_id, removed_at: removed_at}
  end

  def apply(%__MODULE__{} = state, %TodoAdded{} = event) do
    Logger.debug("[Todo.apply(TodoAdded)] Applying event: #{inspect(event)}")

    %__MODULE__{
      state
      | todo_id: event.todo_id,
        name: event.name,
        description: event.description,
        due_date: event.due_date,
        added_at: event.added_at,
        status: :not_started,
        deleted: false
    }
  end

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

  def apply(%__MODULE__{} = state, %TodoRemoved{} = event) do
    Logger.debug("[Todo.apply(TodoRemoved)] Applying event: #{inspect(event)}")
    %__MODULE__{state | deleted: true, updated_at: DateTime.utc_now()}
  end
end

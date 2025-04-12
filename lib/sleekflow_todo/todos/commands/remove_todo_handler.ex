defmodule SleekFlowTodo.Todos.Commands.RemoveTodoHandler do
  @moduledoc """
  Handler for the RemoveTodo command.
  """

  require Logger

  alias SleekFlowTodo.Todos.Commands.RemoveTodo
  alias SleekFlowTodo.Todos.Aggregates.Todo

  def handle(aggregate, command) do
    Logger.info("[RemoveTodoHandler] Received aggregate: #{inspect(aggregate)}")
    Logger.debug("[RemoveTodoHandler] Received command: #{inspect(command)}")
    %RemoveTodo{todo_id: todo_id, removed_at: removed_at} = command
    event = Todo.remove(aggregate, todo_id, removed_at)
    # Assuming success returns the event
    {:ok, event}
  end
end

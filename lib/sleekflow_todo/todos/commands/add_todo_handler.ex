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

    %AddTodo{
      todo_id: todo_id,
      name: name,
      description: description,
      due_date: due_date,
      added_at: added_at
    } = command

    Logger.debug("[AddTodoHandler] Calling Todo.add with todo_id: #{todo_id}")
    result = Todo.add(aggregate, todo_id, name, description, due_date, added_at)
    Logger.debug("[AddTodoHandler] Result from Todo.add: #{inspect(result)}")
    result
  end
end

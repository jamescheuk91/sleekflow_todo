defmodule SleekFlowTodo.Todos.RemoveTodoService do
  @moduledoc """
  Service module for removing a todo item by dispatching a RemoveTodo command.
  """

  require Logger
  alias SleekFlowTodo.Todos.Commands.RemoveTodo
  alias SleekFlowTodo.CommandedApplication

  @doc """
  Dispatches a command to remove a todo item.

  Returns `{:ok, todo_id}` on success, or `{:error, reason}` if dispatching fails.
  """
  def remove_todo(todo_id) when is_binary(todo_id) do
    with command = build_remove_todo_command(todo_id),
         :ok <- dispatch_remove_todo_command(command) do
      {:ok, todo_id}
    else
      # Error from dispatch_add_todo_command
      {:error, {:dispatch, error_details}} ->
        Logger.error("[RemoveTodoService.remove_todo] Dispatch error: #{inspect(error_details)}")
        {:error, error_details}

      # Catch-all for unexpected errors
      other_error ->
        Logger.error("[RemoveTodoService.remove_todo] Unexpected error: #{inspect(other_error)}")
        {:error, {:unexpected, "An unexpected error occurred: #{inspect(other_error)}"}}
    end
  end

  defp build_remove_todo_command(todo_id) do
    struct!(RemoveTodo, %{todo_id: todo_id, removed_at: DateTime.utc_now()})
  end

  defp dispatch_remove_todo_command(command) do
    case CommandedApplication.dispatch(command, consistency: :strong) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end

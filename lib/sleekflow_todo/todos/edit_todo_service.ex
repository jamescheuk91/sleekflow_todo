defmodule SleekFlowTodo.Todos.EditTodoService do
  @moduledoc """
  Service module for handling the editing of Todo items.
  Encapsulates the logic for building and dispatching the `EditTodo` command.
  """

  require Logger

  alias SleekFlowTodo.CommandedApplication
  alias SleekFlowTodo.Todos.Commands.EditTodo

  @doc """
  Edits an existing todo item by building and dispatching an `EditTodo` command.

  Accepts the `todo_id` and a map of attributes to update.

  Returns `{:ok, todo_id}` on successful command dispatch.
  Returns `{:error, reason}` if the command dispatch fails or an unexpected error occurs.

  ## Examples

      iex> EditTodoService.edit_todo("uuid-string", %{name: "Buy groceries"})
      {:ok, "uuid-string"}

      iex> EditTodoService.edit_todo("uuid-string", %{description: "Milk, eggs, bread"})
      {:ok, "uuid-string"}

      iex> EditTodoService.edit_todo("non-existent-uuid", %{name: "Fix sink"})
      {:error, {:dispatch, {:error, :command_error, %SleekflowTodo.Error{message: "Todo not found", type: :not_found}}}}}
  """
  def edit_todo(todo_id, attrs = %{}) do
    Logger.debug("[EditTodoService.edit_todo] Received attributes: #{inspect(attrs)} for todo_id: #{todo_id}")

    command_attrs = Map.put(attrs, :todo_id, todo_id)
    Logger.debug("[EditTodoService.edit_todo] Command attributes: #{inspect(command_attrs)}")

    with command = build_edit_todo_command(command_attrs),
         :ok <- dispatch_edit_todo_command(command) do
      Logger.debug("[EditTodoService.edit_todo] Command dispatched successfully. Returning {:ok, todo_id}")
      {:ok, command.todo_id}
    else
      # Error from dispatch_edit_todo_command
      {:error, {:dispatch, error_details}} ->
        Logger.error("[EditTodoService.edit_todo] Dispatch error: #{inspect(error_details)}")
        {:error, error_details}

      # Catch-all for unexpected errors
      other_error ->
        Logger.error("[EditTodoService.edit_todo] Unexpected error: #{inspect(other_error)}")
        {:error, {:unexpected, "An unexpected error occurred: #{inspect(other_error)}"}}
    end
  end

  defp build_edit_todo_command(attrs) do
    Logger.debug("[EditTodoService.build_edit_todo_command] Building EditTodo command with attrs: #{inspect(attrs)}")
    struct(EditTodo, attrs)
  end

  # Helper returning :ok or {:error, {:dispatch, reason}}
  defp dispatch_edit_todo_command(command) do
    Logger.debug("[EditTodoService.dispatch_edit_todo_command] Dispatching command: #{inspect(command)}")

    case CommandedApplication.dispatch(command, consistency: :strong) do
      :ok ->
        Logger.debug("[EditTodoService.dispatch_edit_todo_command] Dispatch successful.")
        :ok

      {:error, reason} ->
        Logger.error("[EditTodoService.dispatch_edit_todo_command] Dispatch failed: #{inspect(reason)}")
        # Tag the error source
        {:error, {:dispatch, reason}}
    end
  end
end

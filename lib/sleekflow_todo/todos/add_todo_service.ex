defmodule SleekFlowTodo.Todos.AddTodoService do
  @moduledoc """
  Service responsible for adding a new todo item.
  """
  require Logger

  alias SleekFlowTodo.CommandedApplication
  alias SleekFlowTodo.Todos.Commands.AddTodo

  @doc """
  Adds a new todo item.

  Handles command building and dispatching.
  Returns `{:ok, todo_id}` on success or `{:error, reason}` on failure.
  """
  def add_todo(attrs \\ %{}) do
    Logger.debug("[AddTodoService.add_todo] Received attributes: #{inspect(attrs)}")
    todo_id = Commanded.UUID.uuid4()
    Logger.debug("[AddTodoService.add_todo] Using todo_id: #{todo_id}")

    command_attrs = Map.put(attrs, :todo_id, todo_id)
    Logger.debug("[AddTodoService.add_todo] Command attributes: #{inspect(command_attrs)}")

    with command = build_add_todo_command(command_attrs),
         :ok <- dispatch_add_todo_command(command) do
      Logger.debug("[AddTodoService.add_todo] Command dispatched successfully. Returning {:ok, todo_id}")
      {:ok, todo_id}
    else
      # Error from dispatch_add_todo_command
      {:error, {:dispatch, error_details}} ->
        Logger.error("[AddTodoService.add_todo] Dispatch error: #{inspect(error_details)}")
        {:error, error_details}

      # Catch-all for unexpected errors
      other_error ->
        Logger.error("[AddTodoService.add_todo] Unexpected error: #{inspect(other_error)}")
        {:error, {:unexpected, "An unexpected error occurred: #{inspect(other_error)}"}}
    end
  end

  defp build_add_todo_command(attrs) do
    attrs =
      attrs
      |> Map.put(:added_at, DateTime.utc_now())

    struct!(AddTodo, attrs) # Using struct! as errors are not expected here currently
  end

  # Helper returning :ok or {:error, {:dispatch, reason}}
  defp dispatch_add_todo_command(command) do
    Logger.debug("[AddTodoService.dispatch_add_todo_command] Dispatching command: #{inspect(command)}")

    case CommandedApplication.dispatch(command, consistency: :strong) do
      :ok ->
        Logger.debug("[AddTodoService.dispatch_add_todo_command] Dispatch successful.")
        :ok

      {:error, reason} ->
        Logger.error("[AddTodoService.dispatch_add_todo_command] Dispatch failed: #{inspect(reason)}")
        # Tag the error source
        {:error, {:dispatch, reason}}
    end
  end
end

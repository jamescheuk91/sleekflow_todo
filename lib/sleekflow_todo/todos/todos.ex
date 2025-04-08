defmodule SleekFlowTodo.Todos do
  @moduledoc """
  The Todos context.
  """
  require Logger

  alias SleekFlowTodo.CommandedApplication

  alias SleekFlowTodo.Todos.Commands.AddTodo

  @doc """
  Adds a new todo item.

  ## Examples

      iex> add_todo(%{description: "Buy milk"})
      {:ok, "Todo added"} # Placeholder response

  """
  def add_todo(attrs = %{}) do
    Logger.debug("[Todos.add_todo] Received attributes: #{inspect(attrs)}")

    with todo_id = Commanded.UUID.uuid4(),
         _ <- Logger.debug("[Todos.add_todo] Using todo_id: #{todo_id}"),
         command_attrs = Map.put(attrs, :todo_id, todo_id),
         _ <- Logger.debug("[Todos.add_todo] Command attributes: #{inspect(command_attrs)}"),
         command = struct(AddTodo, command_attrs),
         _ <- Logger.debug("[Todos.add_todo] Created command: #{inspect(command)}"),
         :ok = dispatch_result = SleekFlowTodo.CommandedApplication.dispatch(command),
         _ <- Logger.debug("[Todos.add_todo] Dispatch result: #{inspect(dispatch_result)}")
     do
        Logger.debug("[Todos.add_todo] Command dispatched successfully. Returning {:ok, todo_id}")
        {:ok, todo_id}
    else
      # Handle struct creation errors
      {:error, %KeyError{} = reason} ->
        Logger.error("[Todos.add_todo] Struct creation error (missing key): #{inspect(reason)}")
        {:error, "Failed to create command due to missing key: #{inspect(reason)}"}

      {:error, %Ecto.Changeset{} = reason} ->
        Logger.error("[Todos.add_todo] Struct creation error (invalid data): #{inspect(reason)}")
        {:error, "Failed to create command due to invalid data: #{inspect(reason)}"}

      # Handle dispatch errors
      {:error, reason} ->
        Logger.error("[Todos.add_todo] Dispatch error: #{inspect(reason)}")
        {:error, "Failed to dispatch command: #{inspect(reason)}"}

      # Catch any other unexpected non-ok results from dispatch or struct
      other_error ->
        Logger.error("[Todos.add_todo] Unexpected intermediate error: #{inspect(other_error)}")
        {:error, "An unexpected error occurred during processing: #{inspect(other_error)}"}
    end
  end
end

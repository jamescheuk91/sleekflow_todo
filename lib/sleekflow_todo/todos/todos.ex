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
      {:ok, "uuid-string"} # Returns {:ok, todo_id} on success

      iex> add_todo(%{})
      {:error, "Failed to create command due to missing key: %KeyError{key: :description, term: %{todo_id: "..."}}"}

  """
  def add_todo(attrs = %{}) do
    Logger.debug("[Todos.add_todo] Received attributes: #{inspect(attrs)}")
    todo_id = Commanded.UUID.uuid4()
    Logger.debug("[Todos.add_todo] Using todo_id: #{todo_id}")

    command_attrs = Map.put(attrs, :todo_id, todo_id)
    Logger.debug("[Todos.add_todo] Command attributes: #{inspect(command_attrs)}")

    with {:ok, command} <- build_add_todo_command(command_attrs),
         :ok <- dispatch_add_todo_command(command) do
      Logger.debug("[Todos.add_todo] Command dispatched successfully. Returning {:ok, todo_id}")
      {:ok, todo_id}
    else
      # Error from build_add_todo_command
      {:error, {:build, error_details}} ->
        Logger.error("[Todos.add_todo] Build command error: #{inspect(error_details)}")
        handle_build_error(error_details)

      # Error from dispatch_add_todo_command
      {:error, {:dispatch, error_details}} ->
        Logger.error("[Todos.add_todo] Dispatch error: #{inspect(error_details)}")
        {:error, "Failed to dispatch command: #{inspect(error_details)}"}

      # Catch-all for unexpected errors (e.g., if helpers return something else)
      other_error ->
        Logger.error("[Todos.add_todo] Unexpected error: #{inspect(other_error)}")
        {:error, "An unexpected error occurred: #{inspect(other_error)}"}
    end
  end

  # Helper returning {:ok, command} or {:error, {:build, reason}}
  defp build_add_todo_command(attrs) do
    # Assuming struct/2 can return the struct OR {:error, reason} based on original else block
    case struct(AddTodo, attrs) do
       # Check if the result is the expected struct type
      %AddTodo{} = command ->
        Logger.debug("[Todos.build_add_todo_command] Built command: #{inspect(command)}")
        {:ok, command}

      {:error, reason} ->
        Logger.error("[Todos.build_add_todo_command] Struct creation failed: #{inspect(reason)}")
        {:error, {:build, reason}} # Tag the error source

      other -> # Handle unexpected return values from struct/2 if any
        Logger.error("[Todos.build_add_todo_command] Unexpected struct result: #{inspect(other)}")
        {:error, {:build, {:unexpected_result, other}}}
    end
  end

  # Helper returning :ok or {:error, {:dispatch, reason}}
  defp dispatch_add_todo_command(command) do
    Logger.debug("[Todos.dispatch_add_todo_command] Dispatching command: #{inspect(command)}")

    case CommandedApplication.dispatch(command) do
      :ok ->
        Logger.debug("[Todos.dispatch_add_todo_command] Dispatch successful.")
        :ok

      {:error, reason} ->
        Logger.error("[Todos.dispatch_add_todo_command] Dispatch failed: #{inspect(reason)}")
        {:error, {:dispatch, reason}} # Tag the error source

      other -> # Handle unexpected return values from dispatch
        Logger.warning("[Todos.dispatch_add_todo_command] Unexpected dispatch result: #{inspect(other)}")
        {:error, {:dispatch, {:unexpected_result, other}}}
    end
  end

  # Helper to map build errors to user-friendly messages
  defp handle_build_error(%KeyError{} = reason) do
    Logger.error("[Todos.handle_build_error] Handling KeyError: #{inspect(reason)}")
    {:error, "Failed to create command due to missing key: #{inspect(reason)}"}
  end

  defp handle_build_error(%Ecto.Changeset{} = reason) do
    Logger.error("[Todos.handle_build_error] Handling Changeset error: #{inspect(reason)}")
    {:error, "Failed to create command due to invalid data: #{inspect(reason)}"}
  end

  defp handle_build_error(other_reason) do
    Logger.error("[Todos.handle_build_error] Handling other build error: #{inspect(other_reason)}")
    # Generic build error
    {:error, "Failed to create command: #{inspect(other_reason)}"}
  end
end

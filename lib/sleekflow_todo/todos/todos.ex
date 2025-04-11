defmodule SleekFlowTodo.Todos do
  @moduledoc """
  The Todos context.
  """
  require Logger

  alias SleekFlowTodo.CommandedApplication
  alias SleekFlowTodo.ProjectionRepo
  alias SleekFlowTodo.Todos.GetTodoListService
  alias SleekFlowTodo.Todos.Commands.AddTodo
  alias SleekFlowTodo.Todos.TodoReadModel

  @doc """
    Returns a list of all todo items from the read model, optionally filtered and sorted.
  """
  defdelegate list_todos(opts \\ []), to: GetTodoListService

  @doc """
  Adds a new todo item.

  ## Examples

      iex> add_todo(%{name: "Buy milk"})
      {:ok, "uuid-string"} # Returns {:ok, todo_id} on success

      iex> add_todo(%{})
      {:error, {:name, "Name is required"}}

  """
  def add_todo(attrs = %{}) do
    Logger.debug("[Todos.add_todo] Received attributes: #{inspect(attrs)}")
    todo_id = Commanded.UUID.uuid4()
    Logger.debug("[Todos.add_todo] Using todo_id: #{todo_id}")

    command_attrs = Map.put(attrs, :todo_id, todo_id)
    Logger.debug("[Todos.add_todo] Command attributes: #{inspect(command_attrs)}")

    with command = build_add_todo_command(command_attrs),
         :ok <- dispatch_add_todo_command(command) do
      Logger.debug("[Todos.add_todo] Command dispatched successfully. Returning {:ok, todo_id}")
      {:ok, todo_id}
    else
      # Error from dispatch_add_todo_command
      {:error, {:dispatch, error_details}} ->
        Logger.error("[Todos.add_todo] Dispatch error: #{inspect(error_details)}")
        {:error, error_details}

      # Catch-all for unexpected errors (e.g., if helpers return something else)
      other_error ->
        Logger.error("[Todos.add_todo] Unexpected error: #{inspect(other_error)}")
        {:error, "An unexpected error occurred: #{inspect(other_error)}"}
    end
  end

  # Helper returning {:ok, command} or {:error, {:build, reason}}
  defp build_add_todo_command(attrs) do
    attrs =
      attrs
      |> Map.put(:added_at, DateTime.utc_now())

    struct(AddTodo, attrs)
  end

  # Helper returning :ok or {:error, {:dispatch, reason}}
  defp dispatch_add_todo_command(command) do
    Logger.debug("[Todos.dispatch_add_todo_command] Dispatching command: #{inspect(command)}")

    case CommandedApplication.dispatch(command, consistency: :strong) do
      :ok ->
        Logger.debug("[Todos.dispatch_add_todo_command] Dispatch successful.")
        :ok

      {:error, reason} ->
        Logger.error("[Todos.dispatch_add_todo_command] Dispatch failed: #{inspect(reason)}")
        # Tag the error source
        {:error, {:dispatch, reason}}
    end
  end

  # # Helper to map build errors to user-friendly messages
  # defp handle_build_error(%KeyError{} = reason) do
  #   Logger.error("[Todos.handle_build_error] Handling KeyError: #{inspect(reason)}")
  #   {:error, "Failed to create command due to missing key: #{inspect(reason)}"}
  # end

  # defp handle_build_error(other_reason) do
  #   Logger.error("[Todos.handle_build_error] Handling other build error: #{inspect(other_reason)}")
  #   # Generic build error
  #   {:error, "Failed to create command: #{inspect(other_reason)}"}
  # end

  @doc """
  Retrieves a single todo item by its ID from the read model.

  Returns the `TodoReadModel` struct if found, otherwise `nil`.

  ## Examples

      iex> get_todo("valid-uuid")
      %TodoReadModel{}

      iex> get_todo("invalid-uuid")
      nil
  """
  def get_todo(id) do
    ProjectionRepo.get(TodoReadModel, id)
  end
end

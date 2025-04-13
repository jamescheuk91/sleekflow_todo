defmodule SleekFlowTodo.Todos do
  @moduledoc """
  The Todos context.
  """
  require Logger

  alias SleekFlowTodo.Todos.AddTodoService
  alias SleekFlowTodo.Todos.EditTodoService
  alias SleekFlowTodo.Todos.GetTodoItemService
  alias SleekFlowTodo.Todos.GetTodoListService
  alias SleekFlowTodo.Todos.RemoveTodoService

  @doc """
    Returns a list of all todo items from the read model, optionally filtered and sorted.
  """
  defdelegate list_todos(opts \\ []), to: GetTodoListService

  @doc """
  Retrieves a single todo item by its ID from the read model.
  """
  defdelegate get_todo(id), to: GetTodoItemService

  defdelegate get_todo!(id), to: GetTodoItemService

  @doc """
  Adds a new todo item.

  ## Examples

      iex> add_todo(%{name: "Buy milk"})
      {:ok, "uuid-string"} # Returns {:ok, todo_id} on success

      iex> add_todo(%{})
      {:error, {:name, "Name is required"}}

  """
  defdelegate add_todo(attrs \\ %{}), to: AddTodoService

  @doc """
  Edits an existing todo item. Delegates to `SleekFlowTodo.Todos.EditTodoService`.
  """
  defdelegate edit_todo(todo_id, attrs \\ %{}), to: EditTodoService

  @doc """
  Removes an existing todo item. Delegates to `SleekFlowTodo.Todos.RemoveTodoService`.
  """
  defdelegate remove_todo(todo_id), to: RemoveTodoService
end

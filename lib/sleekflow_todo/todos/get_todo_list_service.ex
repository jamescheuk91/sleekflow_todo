defmodule SleekFlowTodo.Todos.GetTodoListService do
  @moduledoc """
  Service responsible for querying and filtering TodoReadModel items.
  """

  alias SleekFlowTodo.ProjectionRepo
  alias SleekFlowTodo.Todos.TodoReadModel
  import Ecto.Query

  @doc """
  Returns a list of all todo items from the read model, optionally filtered by status and/or due date.

  ## Examples

      iex> list_todos()
      [%TodoReadModel{}, ...]

      iex> list_todos(status: "pending")
      [%TodoReadModel{status: "pending"}, ...]

      iex> list_todos(due_date: ~U[2024-01-01 10:00:00Z])
      [%TodoReadModel{due_date: ~U[2024-01-01 10:00:00Z]}, ...]

      iex> list_todos(status: "completed", due_date: ~U[2024-01-01 10:00:00Z])
      [%TodoReadModel{status: "completed", due_date: ~U[2024-01-01 10:00:00Z]}, ...]
  """
  def list_todos(filters \\ %{}) do
    TodoReadModel
    |> where(filter_query(filters))
    |> ProjectionRepo.all()
  end

  @doc """
  Builds an Ecto dynamic query based on the provided filters.
  Currently supports filtering by `:status` (string) and `:due_date` (DateTime).
  """
  def filter_query(filters) do
    Enum.reduce(filters, dynamic(true), fn
      {:status, status}, dynamic when is_binary(status) ->
        dynamic([q], q.status == ^status and ^dynamic)
      {:due_date, due_date}, dynamic when is_struct(due_date, DateTime) ->
        dynamic([q], q.due_date == ^due_date and ^dynamic)
      # Ignore unknown or invalid filter keys/values
      {_, _}, dynamic ->
        dynamic
    end)
  end
end

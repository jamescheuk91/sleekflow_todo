defmodule SleekFlowTodo.Todos.GetTodoListService do
  @moduledoc """
  Service responsible for querying, filtering, and sorting TodoReadModel items.
  """

  alias SleekFlowTodo.ProjectionRepo
  alias SleekFlowTodo.Todos.TodoReadModel
  import Ecto.Query

  @doc """
  Returns a list of all todo items from the read model, optionally filtered and sorted.

  ## Options

  Accepts a keyword list `opts` with the following keys:

  * `:filters`: A map of filters. Supported keys: `:status` (string), `:due_date` (DateTime).
  * `:sort`: A map specifying sorting criteria. Supported keys:
    * `:field`: The field to sort by (atom: `:due_date`, `:status`, `:name`).
    * `:direction`: The sort direction (atom: `:asc` or `:desc`).
  Defaults to sorting by `:name` ascending if `:sort` is not provided or invalid.

  ## Examples

      # List all todos, default sort (name asc)
      iex> list_todos()
      [%TodoReadModel{}, ...]

      # Filter by status, default sort
      iex> list_todos(filters: %{status: "pending"})
      [%TodoReadModel{status: "pending"}, ...]

      # Filter by due date, sort by status descending
      iex> list_todos(filters: %{due_date: ~U[2024-01-01 10:00:00Z]}, sort: %{field: :status, direction: :desc})
      [%TodoReadModel{status: "completed", due_date: ~U[2024-01-01 10:00:00Z]}, ...] # Example assumes data sorted desc

      # Sort by due date ascending
      iex> list_todos(sort: %{field: :due_date, direction: :asc})
      [%TodoReadModel{}, ...]
  """
  def list_todos(opts \\ []) do
    filters = Keyword.get(opts, :filters, %{})
    # Default sort if not provided or invalid in apply_sorting
    sort_opts = Keyword.get(opts, :sort)

    TodoReadModel
    |> where(^filter_query(filters))
    |> apply_sorting(sort_opts)
    |> ProjectionRepo.all()
  end

  @doc """
  Builds an Ecto dynamic query based on the provided filters.
  Currently supports filtering by `:status` (string) and `:due_date` (DateTime).
  """
  def filter_query(filters) do
    Enum.reduce(filters, dynamic(true), fn
      {:status, status}, dynamic when is_atom(status) and status in [:not_started, :in_progress, :completed] ->
        dynamic([q], q.status == ^status and ^dynamic)

      {:due_date, due_date}, dynamic when is_struct(due_date, DateTime) ->
        dynamic([q], q.due_date <= ^due_date and ^dynamic)

      # Ignore unknown or invalid filter keys/values
      {_, _}, dynamic ->
        dynamic
    end)
  end

  # Private helper to apply sorting
  defp apply_sorting(query, %{field: field, direction: direction})
       when field in [:due_date, :status, :name] and direction in [:asc, :desc] do
    # Construct the order_by keyword list dynamically
    order_by_opts = Keyword.put([], direction, field)
    order_by(query, ^order_by_opts) # Use the dynamically created keyword list
  end

  # Apply default sort if sort_opts are invalid or nil
  defp apply_sorting(query, _invalid_or_nil_sort_opts) do
    # Default sort by name ascending
    order_by(query, asc: :name)
  end
end

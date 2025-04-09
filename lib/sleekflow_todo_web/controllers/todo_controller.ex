defmodule SleekFlowTodoWeb.TodoController do
  use SleekFlowTodoWeb, :controller
  require Logger
  alias SleekFlowTodo.Todos
  alias SleekFlowTodoWeb.TodoJSON

  action_fallback SleekFlowTodoWeb.FallbackController

  def index(conn, params) do
    filters = parse_index_filters(params)
    todos = Todos.list_todos(filters)
    render(conn, TodoJSON, :index, todos: todos)
  end

  def create(conn, %{"todo" => todo_params}) do
    params = SleekFlowTodo.Utils.key_to_atom(todo_params)
    # Convert due_date from string to DateTime if present
    params = parse_due_date(params)
    with {:ok, todo_id} <- Todos.add_todo(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/todos/#{todo_id}")
      |> json(%{data: %{id: todo_id}})
    else
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: SleekFlowTodoWeb.ErrorJSON)
        |> render(:error, reason: reason)
    end
  end

  def show(conn, %{"id" => id}) do
    case Todos.get_todo(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(json: SleekFlowTodoWeb.ErrorJSON)
        |> render("404.json", %{})
      todo ->
        conn
        |> put_status(:ok)
        |> put_view(json: SleekFlowTodoWeb.TodoJSON)
        |> render(:show, todo: todo)
    end
  end

  defp parse_due_date(params) do
    if Map.has_key?(params, :due_date) and is_binary(params.due_date) do
      case DateTime.from_iso8601(params.due_date) do
        {:ok, datetime, _offset} ->
          Map.put(params, :due_date, datetime)
        {:error, reason} ->
          # Keep the original value, the validation in the command will handle the error
          Logger.error("Failed to parse due_date: #{inspect(reason)}")
          params
      end
    else
      params
    end
  end

  defp parse_index_filters(params) do
    filters = %{}

    filters =
      case Map.get(params, "status") do
        nil -> filters
        status -> Map.put(filters, :status, status)
      end

    case Map.get(params, "due_date") do
      nil -> filters
      date_string when is_binary(date_string) ->
        case DateTime.from_iso8601(date_string) do
          {:ok, datetime, _offset} ->
            Map.put(filters, :due_date, datetime)
          {:error, _} ->
            # Ignore invalid date strings for filtering
            filters
        end
      _ -> filters # Ignore non-string due_date params
    end
  end
end

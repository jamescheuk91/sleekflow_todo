defmodule SleekFlowTodoWeb.TodoController do
  use SleekFlowTodoWeb, :controller
  require Logger
  alias SleekFlowTodo.Todos
  alias SleekFlowTodoWeb.TodoJSON

  action_fallback SleekFlowTodoWeb.FallbackController

  def index(conn, _params) do
    todos = Todos.list_todos()
    conn
    |> put_view(json: TodoJSON)
    render(conn, :index, todos: todos)
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
end

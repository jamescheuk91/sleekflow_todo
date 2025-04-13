defmodule SleekFlowTodoWeb.TodoController do
  use SleekFlowTodoWeb, :controller
  use PhoenixSwagger
  require Logger
  alias SleekFlowTodo.Todos
  alias SleekFlowTodoWeb.TodoJSON
  alias SleekFlowTodoWeb.ErrorJSON
  alias SleekFlowTodoWeb.TodoParamsParser

  action_fallback SleekFlowTodoWeb.FallbackController

  swagger_path :index do
    get("/todos")
    summary("List all todos")
    description("Retrieve a list of all todos")
    produces(["application/json"])
    tag("Todos")

    parameters do
      status(:query, :array, "Status filter",
        items: [type: :string, enum: [:not_started, :in_progress, :completed]]
      )
      due_date(:query, :string, "DateTime in ISO8601", example: "2025-04-15T15:25:11.550132Z")
      sort_by(:query, :string, "Sort by", example: "priority")
      sort_order(:query, :string, "Sort order", example: "asc")
    end
  end

  def index(conn, params) do
    filters = TodoParamsParser.parse_index_filters(params)
    sort = TodoParamsParser.parse_index_sort(params)
    opts = [filters: filters, sort: sort]

    todos = Todos.list_todos(opts)

    conn
    |> put_view(json: TodoJSON)
    |> render(:index, todos: todos)
  end

  def create(conn, %{"todo" => todo_params}) do
    with {:ok, parsed_params} <- TodoParamsParser.parse_create_params(todo_params),
         {:ok, todo_id} <- Todos.add_todo(parsed_params),
         todo <- Todos.get_todo!(todo_id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/todos/#{todo_id}")
      |> put_view(json: TodoJSON)
      |> render(:show, todo: todo)
    else
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: ErrorJSON)
        |> render(:error, reason: reason)
    end
  end

  def show(conn, %{"id" => id}) do
    case Todos.get_todo(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(json: ErrorJSON)
        |> render("404.json", %{})

      todo ->
        conn
        |> put_status(:ok)
        |> put_view(json: TodoJSON)
        |> render(:show, todo: todo)
    end
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    case Todos.get_todo(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(json: ErrorJSON)
        |> render("404.json", %{})

      _existing_todo ->
        with {:ok, parsed_params} <- TodoParamsParser.parse_update_params(todo_params),
             {:ok, todo_id} <- Todos.edit_todo(id, parsed_params),
             updated_todo <- Todos.get_todo!(todo_id) do
          conn
          |> put_status(:ok)
          |> put_view(json: TodoJSON)
          |> render(:show, todo: updated_todo)
        else
          {:error, reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(json: ErrorJSON)
            |> render(:error, reason: reason)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Todos.get_todo(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(json: ErrorJSON)
        |> render("404.json", %{})

      _todo ->
        with {:ok, _} <- Todos.remove_todo(id) do
          send_resp(conn, :no_content, "")
        else
          {:error, reason} ->
            Logger.error("Error deleting todo #{id}: #{inspect(reason)}")

            conn
            |> put_status(:internal_server_error)
            |> put_view(json: ErrorJSON)
            |> render(:error, reason: reason)
        end
    end
  end
end

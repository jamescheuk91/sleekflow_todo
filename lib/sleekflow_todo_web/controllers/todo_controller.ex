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

    response(200, "Success")
  end

  swagger_path :create do
    post("/todos")
    summary("Create a new todo")
    description("Add a new todo item to the list")
    consumes(["application/json"])
    produces(["application/json"])
    tag("Todos")

    parameters do
      todo(:body, Schema.ref(:Todo), "Todo object to create", required: true)
    end

    response(201, "Created", Schema.ref(:Todo))
    response(422, "Unprocessable Entity")
  end

  swagger_path :show do
    get("/todos/:id")
    summary("Show a specific todo")
    description("Retrieve a specific todo item by its ID")
    produces(["application/json"])
    tag("Todos")

    parameters do
      id(:path, :string, "Todo ID",
        required: true,
        example: "02ef07e0-eb4f-4fca-b6aa-c7993427cc10"
      )
    end

    response(200, "OK", Schema.ref(:Todo))
    response(404, "Not Found")
  end

  swagger_path :update do
    put("/todos/:id")
    summary("Update an existing todo")
    description("Update the details of a specific todo item")
    consumes(["application/json"])
    produces(["application/json"])
    tag("Todos")

    parameters do
      id(:path, :string, "Todo ID", required: true, example: "02ef07e0-eb4f-4fca-b6aa-c7993427cc10")
      todo(:body, Schema.ref(:Todo), "Todo object with updated details", required: true)
    end

    response(200, "OK", Schema.ref(:Todo))
    response(404, "Not Found")
    response(422, "Unprocessable Entity")
  end

  def swagger_definitions do
    %{
      Todo:
        swagger_schema do
          title("Todo")
          description("A todo item")

          properties do
            id(:string, "Unique identifier", required: true)
            name(:string, "todo item name", required: true)
            status(:string, "todo item status", required: true)
            due_date(:string, "todo item due date", required: false)
            priority(:string, "todo item priority", required: false)
            description(:string, "todo item description", required: false)
            tags(:array, "todo item tags", required: false)
            updated_at(:string, "todo item updated at", required: false)
            added_at(:string, "todo item added at", required: false)
          end

          example(%{
            id: "02ef07e0-eb4f-4fca-b6aa-c7993427cc10",
            name: "test new",
            priority: "high",
            status: "in_progress",
            description: "description new",
            tags: [
              "test1",
              "test3"
            ],
            updated_at: "2025-04-13T07:05:25.345643Z",
            due_date: "2025-04-14T15:28:42.596658Z",
            added_at: "2025-04-09T11:25:30.867826Z"
          })
        end,
      Todos:
        swagger_schema do
          title("Todos")
          description("A collection of Todos")
          type(:array)
          items(Schema.ref(:Todo))
        end
    }
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

defmodule SleekFlowTodoWeb.TodoController do
  use SleekFlowTodoWeb, :controller
  require Logger
  alias SleekFlowTodo.Todos
  alias SleekFlowTodoWeb.TodoJSON
  alias SleekFlowTodoWeb.ErrorJSON

  action_fallback SleekFlowTodoWeb.FallbackController

  def index(conn, params) do
    filters = parse_index_filters(params)
    sort = parse_index_sort(params)
    opts = [filters: filters, sort: sort]

    todos = Todos.list_todos(opts)

    conn
    |> put_view(json: TodoJSON)
    |> render(:index, todos: todos)
  end

  def create(conn, %{"todo" => todo_params}) do
    params = SleekFlowTodo.Utils.key_to_atom(todo_params)
    # Convert due_date from string to DateTime if present
    params = parse_due_date(params)

    with {:ok, todo_id} <- Todos.add_todo(params),
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
        # Todo exists, proceed with the update logic
        params = SleekFlowTodo.Utils.key_to_atom(todo_params)
        # Convert due_date from string to DateTime if present
        params = parse_due_date(params)

        with {:ok, todo_id} <- Todos.edit_todo(id, params),
             # Fetch the updated todo state after the command is processed
             updated_todo <- Todos.get_todo!(todo_id) do
          conn
          |> put_status(:ok)
          |> put_view(json: TodoJSON)
          |> render(:show, todo: updated_todo)
        else
          # Handle errors from Todos.edit_todo (e.g., validation)
          {:error, reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(json: ErrorJSON)
            |> render(:error, reason: reason)
        end
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
        status_string when is_binary(status_string) ->
          case String.to_existing_atom(status_string) do
            atom when is_atom(atom) -> Map.put(filters, :status, atom)
            # Ignore invalid status strings for filtering
            _ -> filters
          end
        # Ignore non-string status params
        _ -> filters
      end

    case Map.get(params, "due_date") do
      nil ->
        filters

      date_string when is_binary(date_string) ->
        case DateTime.from_iso8601(date_string) do
          {:ok, datetime, _offset} ->
            Map.put(filters, :due_date, datetime)

          {:error, _} ->
            # Ignore invalid date strings for filtering
            filters
        end

      # Ignore non-string due_date params
      _ ->
        filters
    end
  end

  defp parse_index_sort(params) do
    with {:ok, field} <- Map.fetch(params, "sort_field"),
         {:ok, direction} <- Map.fetch(params, "sort_direction"),
         field_atom when is_atom(field_atom) <- String.to_existing_atom(field),
         direction_atom when is_atom(direction_atom) <- String.to_existing_atom(direction) do
      %{field: field_atom, direction: direction_atom}
    else
      _ ->
        nil
    end
  end
end

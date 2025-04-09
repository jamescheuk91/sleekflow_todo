defmodule SleekFlowTodoWeb.TodoController do
  use SleekFlowTodoWeb, :controller

  alias SleekFlowTodo.Todos

  action_fallback SleekFlowTodoWeb.FallbackController

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
          IO.puts("Failed to parse due_date: #{inspect(reason)}")
          params
      end
    else
      params
    end
  end
end

defmodule SleekFlowTodoWeb.FallbackController do
  use SleekFlowTodoWeb, :controller


  # Handle generic :not_found errors
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found) # 404
    |> put_view(json: SleekFlowTodoWeb.ErrorJSON) # Use a generic ErrorJSON view
    |> render(:"404")
  end

  # Add clauses here for other errors you want to handle, e.g.:
  # def call(conn, {:error, :unauthorized}) do
  #   conn
  #   |> put_status(:unauthorized) # 401
  #   |> put_view(json: SleekFlowTodoWeb.ErrorJSON)
  #   |> render(:"401", message: "Unauthorized")
  # end
end

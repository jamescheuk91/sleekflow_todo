defmodule SleekFlowTodo.ProjectionRepo do
  use Ecto.Repo,
    otp_app: :sleekflow_todo,
    adapter: Ecto.Adapters.Postgres
end

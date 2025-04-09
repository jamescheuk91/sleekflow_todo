defmodule SleekFlowTodo.CommandedApplication do
  use Commanded.Application, otp_app: :sleekflow_todo

  router(SleekFlowTodo.Todos.Router)
end

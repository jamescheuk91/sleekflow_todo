# test/test_helper.exs

# Load support files before starting ExUnit
Path.wildcard("test/support/**/*.exs")
|> Enum.each(&Code.require_file(&1))

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SleekFlowTodo.ProjectionRepo, :manual)

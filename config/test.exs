import Config

# Configure your eventstore database
config :sleekflow_todo, SleekFlowTodo.EventStore,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "postgres",
  password: "postgres",
  database: "sleekflow_todo_eventstore_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost"

# Configure your projectiondatabase
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :sleekflow_todo, SleekFlowTodo.ProjectionRepo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "sleekflow_todo_projection_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sleekflow_todo, SleekFlowTodoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Rx6jm06eGCBZuysnnFQvyhqixsy20nr1aI53SFcd7C4Djlf9wBboeISWwWDhuSZN",
  server: false

# In test we don't send emails
config :sleekflow_todo, SleekFlowTodo.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

defmodule SleekFlowTodo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SleekFlowTodoWeb.Telemetry,
      SleekFlowTodo.ProjectionRepo,
      SleekFlowTodo.CommandedApplication,
      {Phoenix.PubSub, name: SleekFlowTodo.PubSub},
      # Start Finch
      {Finch, name: SleekFlowTodo.Finch},
      {DNSCluster, query: Application.get_env(:sleekflow_todo, :dns_cluster_query) || :ignore},
      # Start the Endpoint (http/https)
      SleekFlowTodoWeb.Endpoint
      # Start a worker by calling: SleekFlowTodo.Worker.start_link(arg)
      # {SleekFlowTodo.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SleekFlowTodo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, removed) do
    SleekFlowTodoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

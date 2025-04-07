defmodule SleekFlowTodo.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :sleekflow_todo

  def init_event_store do
    load_app()

    config = SleekFlowTodo.EventStore.config()

    :ok = EventStore.Tasks.Create.exec(config)
  end

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    # This prevents the {:error, {:already_loaded, :sleekflow_todo}} error
    case Application.load(@app) do
      :ok -> :ok
      {:error, {:already_loaded, :sleekflow_todo}} -> :ok
    end

    Application.ensure_all_started(@app)
  end
end

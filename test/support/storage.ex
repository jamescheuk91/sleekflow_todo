defmodule SleekFlowTodo.TestSupport.Storage do
  @doc """
  Clear the event store and read store databases
  """

  require Logger

  def reset! do
    reset_eventstore()
    reset_readstore()
  end

  defp reset_eventstore do
    config = SleekFlowTodo.EventStore.config()
    Logger.debug("--- Test Support: Resetting eventstore with config: #{inspect(config)} ---")

    case Postgrex.start_link(config) do
      {:ok, conn} ->
        try do
          EventStore.Storage.Initializer.reset!(conn, config)
        rescue
          e ->
            Logger.error("Failed to reset eventstore: #{inspect(e)}")
            raise e
        end

      {:error, reason} ->
        Logger.error("Failed to connect to eventstore: #{inspect(reason)}")
        raise "Failed to connect to eventstore: #{inspect(reason)}"
    end
  end

  defp reset_readstore do
    config = Application.get_env(:sleekflow_todo, SleekFlowTodo.ProjectionRepo)
    Logger.debug("--- Test Support: Resetting readstore with config: #{inspect(config)} ---")
    # Rely on DataCase to manage the sandbox checkout
    Ecto.Adapters.SQL.query!(SleekFlowTodo.ProjectionRepo, truncate_readstore_tables(), [])
  end

  defp truncate_readstore_tables do
    """
    TRUNCATE TABLE
    todos
    RESTART IDENTITY
    CASCADE;
    """
  end
end

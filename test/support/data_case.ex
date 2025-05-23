defmodule SleekFlowTodo.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use SleekFlowTodo.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate
  require Logger

  using do
    quote do
      alias SleekFlowTodo.ProjectionRepo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Commanded.Assertions.EventAssertions
      import SleekFlowTodo.DataCase
    end
  end

  setup tags do
    require Logger
    # Set up the sandbox first and capture the owner PID
    {:ok, owner_pid: owner_pid} = SleekFlowTodo.DataCase.setup_sandbox(tags)

    # Allow the test process itself to use the connection owned by owner_pid
    Ecto.Adapters.SQL.Sandbox.allow(SleekFlowTodo.ProjectionRepo, self(), owner_pid)

    Logger.info("--- Test Setup: Starting Storage Reset ---")
    # Explicitly reset storage before each test, now that sandbox is ready
    SleekFlowTodo.TestSupport.Storage.reset!()
    Logger.info("--- Test Setup: Storage Reset Complete ---")

    :ok
  end

  @doc """
  Sets up the sandbox based on the test tags.
  """
  def setup_sandbox(tags) do
    {:ok, _} = Application.ensure_all_started(:sleekflow_todo)

    pid =
      Ecto.Adapters.SQL.Sandbox.start_owner!(SleekFlowTodo.ProjectionRepo,
        shared: not tags[:async]
      )

    on_exit(fn ->
      Logger.debug("--- Test on exit ---")

      Logger.info("--- Test Setup: Starting Storage Reset ---")
      # Explicitly reset storage before each test, now that sandbox is ready
      SleekFlowTodo.TestSupport.Storage.reset!()
      Logger.info("--- Test Setup: Storage Reset Complete ---")
      Ecto.Adapters.SQL.Sandbox.stop_owner(pid)

      case Application.stop(:sleekflow_todo) do
        :ok ->
          :ok

        {:error, reason} ->
          IO.puts("Error stopping sleekflow_todo: #{inspect(reason)}")
          :ok
      end
    end)

    {:ok, owner_pid: pid}
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end

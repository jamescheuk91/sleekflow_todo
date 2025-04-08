defmodule SleekFlowTodo.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :sleekflow_todo

  # Number of retries for DB connection
  @db_connect_retries 10
  # Delay between retries in milliseconds
  @db_connect_delay_ms 2000

  def run_tasks do
    # Ensure connectivity first (this also loads/starts the app)
    load_app()

    IO.puts("Setting up EventStore...")
    setup_event_store()

    IO.puts("Creating Ecto Repo databases...")
    create_ecto_repos()

    IO.puts("Migrating Ecto Repos...")
    migrate_ecto_repos()

    IO.puts("Release tasks completed successfully.")
  end

  defp setup_event_store do
    config = SleekFlowTodo.EventStore.config()

    case EventStore.Tasks.Create.exec(config) do
      :ok ->
        IO.puts("EventStore database created or already exists.")

      {:error, :already_exists} ->
        IO.puts("EventStore database already exists.")

      {:error, reason} ->
        IO.puts("Failed to create EventStore database: #{inspect(reason)}")
        System.halt(1)
    end

    case EventStore.Tasks.Init.exec(config) do
      :ok ->
        IO.puts("EventStore database initialized or already initialized.")
    end
  end

  defp create_ecto_repos do
    for repo <- ecto_repos() do
      IO.puts("Ensuring database storage exists for #{inspect(repo)}...")
      config = repo.config()
      # Get the adapter module from the repo
      adapter = repo.__adapter__()

      # Ensure the adapter implements the necessary storage behaviour
      unless function_exported?(adapter, :storage_up, 1) do
        Mix.raise(
          "#{inspect(adapter)} does not implement Ecto.Adapter.Storage (missing storage_up/1)"
        )
      end

      try do
        # Call storage_up on the repo's specific adapter
        case adapter.storage_up(config) do
          :ok ->
            IO.puts("Database storage for #{inspect(repo)} created successfully.")

          {:error, :already_up} ->
            IO.puts("Database storage for #{inspect(repo)} already exists.")

          # Handle other potential non-error returns, just in case
          other ->
            IO.puts(
              "Database storage for #{inspect(repo)} returned unexpected success value: #{inspect(other)}."
            )
        end
      catch
        # Catch other errors that might be raised instead of returned
        type, reason ->
          stacktrace = __STACKTRACE__
          normalized_exception = Exception.normalize(type, reason, stacktrace)
          # Log the actual exception
          IO.inspect(normalized_exception,
            label: "Caught Exception in create_ecto_repos fallback"
          )

          # Specifically check if it's a Postgrex error for duplicate database
          pg_code =
            case normalized_exception do
              %Postgrex.Error{postgres: %{code: code}} -> code
              _ -> nil
            end

          # Postgrex code for "duplicate_database" is "42P04"
          if pg_code == "42P04" do
            IO.puts("Database for #{inspect(repo)} already exists (Caught PG Code 42P04).")
          else
            IO.puts(
              "Failed to ensure database storage for #{inspect(repo)}. Error: #{inspect(normalized_exception)}"
            )

            # Use reraise/2 as shown in Elixir documentation for re-throwing
            # from within a rescue block while preserving the stacktrace.
            reraise reason, stacktrace
          end
      end
    end
  end

  defp migrate_ecto_repos do
    for repo <- ecto_repos() do
      IO.puts("Migrating #{inspect(repo)}...")

      # Define the migration function to be executed within the lock
      migration_fun = fn locked_repo ->
        # Run migrations up
        Ecto.Migrator.run(locked_repo, :up, all: true)
        # Ecto.Migrator.run returns {:ok, migrated_count, ran_count} on success
      end

      # Use with_repo to handle locking. Pattern match asserts success.
      # This will raise MatchError if migration_fun fails or with_repo cannot get the lock.
      {:ok, _migration_result, _lock_ref} = Ecto.Migrator.with_repo(repo, migration_fun)

      # If the above line didn't crash, migration was successful.
      IO.puts("#{inspect(repo)} migrated successfully.")
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp ecto_repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    # This prevents the {:error, {:already_loaded, :sleekflow_todo}} error
    case Application.load(@app) do
      :ok ->
        :ok

      {:error, {:already_loaded, :sleekflow_todo}} ->
        :ok

      {:error, reason} ->
        IO.puts("Failed to load application: #{inspect(reason)}")
        # Exit if app cannot be loaded
        System.halt(1)
    end

    # Ensure all applications are started _before_ checking DBs
    Application.ensure_all_started(@app)

    # Wait for databases
    wait_for_databases(ecto_repos(), @db_connect_retries)
  end

  defp wait_for_databases(repos, retries_left) when retries_left > 0 do
    connected_repos =
      Enum.filter(repos, fn repo ->
        # Use a simple query to check connectivity instead of ready?/1
        case Ecto.Adapters.SQL.query(repo, "SELECT 1", []) do
          {:ok, _} ->
            IO.puts("Database #{inspect(repo)} is ready.")
            true

          {:error, reason} ->
            IO.puts("Database #{inspect(repo)} not ready yet: #{inspect(reason)}")
            false
        end
      end)

    if Enum.count(connected_repos) == Enum.count(repos) do
      IO.puts("All databases are ready.")
      :ok
    else
      IO.puts(
        "Waiting #{@db_connect_delay_ms}ms for databases to become ready... (#{retries_left - 1} retries left)"
      )

      Process.sleep(@db_connect_delay_ms)
      wait_for_databases(repos, retries_left - 1)
    end
  end

  defp wait_for_databases(_repos, 0) do
    IO.puts("Databases did not become ready after #{@db_connect_retries} retries. Aborting.")
    # Exit with a non-zero status to fail the release command
    System.halt(1)
  end
end

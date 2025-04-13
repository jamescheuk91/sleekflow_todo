# lib/sleekflow_todo/activities/activity_feed_projector.ex
defmodule SleekFlowTodo.Activities.ActivityFeedProjector do
  use Commanded.Projections.Ecto,
    application: SleekFlowTodo.CommandedApplication,
    repo: SleekFlowTodo.ProjectionRepo,
    name: "ActivitiesFeedProjector",
    consistency: :strong

  require Logger

  alias SleekFlowTodo.Todos.Events.TodoAdded
  alias SleekFlowTodo.Todos.Events.TodoEdited
  alias SleekFlowTodo.Activities.ActivityFeedItem

  project(%TodoAdded{} = event, metadata, fn multi ->
    details = Map.take(event, [:name, :description, :status, :priority, :due_date, :tags])

    # Safely access metadata, defaulting to event.added_at
    occurred_at = Map.get(metadata, :inserted_at, event.added_at)

    struct = %ActivityFeedItem{
      id: Commanded.UUID.uuid4(),
      todo_id: event.todo_id,
      type: "todo_added",
      details: details,
      occurred_at: occurred_at
    }

    Ecto.Multi.insert(multi, :insert_activity_feed_item, struct)
  end)

  project(%TodoEdited{} = event, metadata, fn multi ->
    # Filter out nil values from the event to only store actual changes
    changes = Map.from_struct(event) |> Enum.reject(fn {k, v} -> k == :todo_id or is_nil(v) end) |> Map.new()

    # Only record the feed item if there were actual changes other than todo_id
    if map_size(changes) > 0 do
      # Safely access metadata, defaulting to DateTime.utc_now()
      occurred_at = Map.get(metadata, :inserted_at, DateTime.utc_now())

      struct = %ActivityFeedItem{
        id: Commanded.UUID.uuid4(),
        todo_id: event.todo_id,
        type: "todo_edited",
        details: changes,
        occurred_at: occurred_at
      }

      Ecto.Multi.insert(multi, :insert_activity_feed_item, struct)
    else
      Logger.info("Skipping ActivityFeedItem for TodoEdited event with no changes: #{inspect(event)}")
      multi
    end
  end)
end

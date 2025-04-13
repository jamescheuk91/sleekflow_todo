# lib/sleekflow_todo_web/controllers/activity_feed_controller.ex
defmodule SleekFlowTodoWeb.ActivityFeedController do
  use SleekFlowTodoWeb, :controller
  use PhoenixSwagger

  alias PhoenixSwagger.Schema
  alias SleekFlowTodo.Activities
  alias SleekFlowTodoWeb.ActivityFeedJSON

  action_fallback SleekFlowTodoWeb.FallbackController

  swagger_path :index do
    get("/activities")
    summary("List Activity Feed Items")
    description("Returns a list of recent activities related to TODOs.")
    produces("application/json")
    tag("Activities")
    # Add parameters for pagination if needed later
    # parameter :query, :integer, :limit, "Limit the number of items returned", default: 50
    # parameter :query, :integer, :offset, "Offset for pagination", default: 0
    # Reference the list schema
    response(200, "OK", Schema.ref(:ActivityFeed))
  end

  def swagger_definitions do
    %{
      ActivityFeedItem:
        swagger_schema do
          title("Activity Feed Item")
          description("An entry in the activity feed")

          properties do
            id(:string, "Unique identifier for the feed item", format: "uuid")
            todo_id(:string, "Identifier of the related TODO item", format: "uuid")
            type(:string, "Type of activity (e.g., todo_added, todo_edited)")
            details(:map, "Details of the activity event")
            occurred_at(:string, "Timestamp when the activity occurred", format: "date-time")
            inserted_at(:string, "Timestamp when the feed item was recorded", format: "date-time")
          end

          example(%{
            id: "a1b2c3d4-e5f6-7890-1234-567890abcdef",
            todo_id: "02ef07e0-eb4f-4fca-b6aa-c7993427cc10",
            type: "todo_edited",
            details: %{name: "Updated Task Name", status: "in_progress"},
            occurred_at: "2025-04-13T10:00:00.123456Z",
            inserted_at: "2025-04-13T10:00:00.123456Z"
          })
        end,
      ActivityFeed:
        swagger_schema do
          title("Activity Feed")
          description("A list of activity feed items")
          type(:array)
          items(Schema.ref(:ActivityFeedItem))
        end
    }
  end

  def index(conn, _params) do
    # Simple pagination for now, could be extended later
    opts = [
      # limit: Map.get(params, "limit"), # Example: pass from query params
      # offset: Map.get(params, "offset") # Example: pass from query params
    ]

    feed_items = Activities.list_activity_feed(opts)

    conn
    |> put_view(json: ActivityFeedJSON)
    |> render(:index, items: feed_items)
  end
end

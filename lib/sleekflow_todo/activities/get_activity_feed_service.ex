# lib/sleekflow_todo/activities/get_activity_feed_service.ex
defmodule SleekFlowTodo.Activities.GetActivityFeedService do
  @moduledoc """
  Service responsible for retrieving the activity feed.
  """
  import Ecto.Query, warn: false

  alias SleekFlowTodo.ProjectionRepo
  alias SleekFlowTodo.Activities.ActivityFeedItemReadModel

  @doc """
  Retrieves a list of activity feed items, ordered by occurrence time (newest first).

  Supports pagination via `limit` and `offset` options.
  """
  def list_activity_feed(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)

    query =
      from(a in ActivityFeedItemReadModel,
        order_by: [desc: a.occurred_at],
        limit: ^limit,
        offset: ^offset
      )

    ProjectionRepo.all(query)
  end
end

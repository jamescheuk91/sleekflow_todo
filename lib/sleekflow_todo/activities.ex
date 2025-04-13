# lib/sleekflow_todo/activities.ex
defmodule SleekFlowTodo.Activities do
  @moduledoc """
  The Activities context.
  Handles querying the activity feed.
  """
  alias SleekFlowTodo.Activities.GetActivityFeedService

  @doc """
  Returns a list of activity feed items, ordered by occurrence time (newest first).
  """
  defdelegate list_activity_feed(opts \\ []), to: GetActivityFeedService, as: :list_activity_feed
end

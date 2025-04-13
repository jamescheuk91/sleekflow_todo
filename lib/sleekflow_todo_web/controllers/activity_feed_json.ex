# lib/sleekflow_todo_web/controllers/activity_feed_json.ex
defmodule SleekFlowTodoWeb.ActivityFeedJSON do
  alias SleekFlowTodo.Activities.ActivityFeedItemReadModel

  @doc """
  Renders a list of activity feed items.
  """
  def index(%{items: items}) do
    %{data: for(item <- items, do: data(item))}
  end

  # While there's no dedicated 'show' endpoint for a single feed item yet,
  # having this function aligns with the pattern and might be useful later.
  @doc """
  Renders a single activity feed item.
  """
  def show(%{item: item}) do
    %{data: data(item)}
  end

  defp data(%ActivityFeedItemReadModel{} = item) do
    %{
      id: item.id,
      todo_id: item.todo_id,
      type: item.type,
      details: item.details, # Details is already a map
      occurred_at: item.occurred_at,
      inserted_at: item.inserted_at
    }
  end
end

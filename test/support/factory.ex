# test/support/factory.ex
defmodule SleekFlowTodo.Factory do
  use ExMachina.Ecto, repo: SleekFlowTodo.ProjectionRepo

  alias SleekFlowTodo.Activities.ActivityFeedItemReadModel

  def activity_feed_item_read_model_factory do
    %ActivityFeedItemReadModel{
      # Default values for required fields
      todo_id: Ecto.UUID.generate(),
      type: "test_activity",
      details: %{info: "test info"},
      occurred_at: DateTime.utc_now()
    }
  end
end

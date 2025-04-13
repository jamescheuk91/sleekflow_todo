defmodule SleekFlowTodo.Activities.GetActivityFeedServiceTest do
  use SleekFlowTodo.DataCase, async: false

  alias SleekFlowTodo.Activities.GetActivityFeedService
  alias SleekFlowTodo.Activities.ActivityFeedItemReadModel
  alias SleekFlowTodo.ProjectionRepo

  import SleekFlowTodo.Factory

  describe "list_activity_feed/1" do
    setup do
      # Clean slate
      ProjectionRepo.delete_all(ActivityFeedItemReadModel)

      # Insert test data with distinct timestamps
      item1 =
        insert(:activity_feed_item_read_model,
          occurred_at: ~U[2024-01-01 10:00:00Z]
        )

      item2 =
        insert(:activity_feed_item_read_model,
          occurred_at: ~U[2024-01-01 12:00:00Z]
        )

      item3 =
        insert(:activity_feed_item_read_model,
          occurred_at: ~U[2024-01-01 11:00:00Z]
        )

      %{item1: item1, item2: item2, item3: item3}
    end

    test "returns activity feed items ordered by occurred_at descending by default", %{
      item1: item1,
      item2: item2,
      item3: item3
    } do
      result_ids = GetActivityFeedService.list_activity_feed() |> Enum.map(& &1.id)
      assert result_ids == [item2.id, item3.id, item1.id]
    end

    test "limits the number of returned items", %{item2: item2, item3: item3} do
      result_ids = GetActivityFeedService.list_activity_feed(limit: 2) |> Enum.map(& &1.id)
      assert result_ids == [item2.id, item3.id]
    end

    test "offsets the returned items", %{item3: item3, item1: item1} do
      result_ids = GetActivityFeedService.list_activity_feed(offset: 1) |> Enum.map(& &1.id)
      assert result_ids == [item3.id, item1.id]
    end

    test "applies both limit and offset", %{item3: item3} do
      result_ids =
        GetActivityFeedService.list_activity_feed(limit: 1, offset: 1) |> Enum.map(& &1.id)

      assert result_ids == [item3.id]
    end

    test "returns an empty list when no activities exist" do
      ProjectionRepo.delete_all(ActivityFeedItemReadModel)
      assert GetActivityFeedService.list_activity_feed() == []
    end
  end
end

defmodule SleekFlowTodoWeb.ActivityFeedControllerTest do
  use SleekFlowTodoWeb.ConnCase, async: false

  # Use the factory alias if defined, otherwise ExMachina functions directly
  # Or your specific factory module alias
  import SleekFlowTodo.Factory
  # Remove unused alias: alias SleekFlowTodo.Activities.ActivityFeedItem

  describe "index/2" do
    test "lists all activity feed items", %{conn: conn} do
      # Use the factory to insert test data
      item1 =
        insert(:activity_feed_item_read_model, %{
          type: "todo_added",
          details: %{name: "Test Todo 1"}
        })

      item2 =
        insert(:activity_feed_item_read_model, %{
          type: "todo_edited",
          details: %{name: "Updated Test Todo 2", status: "in_progress"}
        })

      conn = get(conn, ~p"/api/activities")

      assert response_json = json_response(conn, 200)
      assert length(response_json["data"]) == 2

      # Check if the IDs from the created items are present in the response
      response_ids = Enum.map(response_json["data"], & &1["id"])
      assert item1.id in response_ids
      assert item2.id in response_ids

      # Optionally, check structure/content of one item
      first_item_resp = Enum.find(response_json["data"], &(&1["id"] == item1.id))
      assert first_item_resp["type"] == "todo_added"
      assert first_item_resp["details"]["name"] == "Test Todo 1"
      assert is_binary(first_item_resp["occurred_at"])
      # Check inserted_at as well
      assert is_binary(first_item_resp["inserted_at"])
    end

    test "returns empty list when no activities exist", %{conn: conn} do
      conn = get(conn, ~p"/api/activities")
      assert response_json = json_response(conn, 200)
      assert response_json["data"] == []
    end
  end
end

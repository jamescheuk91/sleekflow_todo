defmodule SleekFlowTodoWeb.TodoControllerTest do
  use SleekFlowTodoWeb.ConnCase, async: false

  alias SleekFlowTodo.Todos

  # Helper function to create a todo and wait for projection
  defp create_todo_and_wait(attrs) do
    {:ok, todo_id} = SleekFlowTodo.Todos.add_todo(attrs)
    # Wait briefly for projection to potentially catch up
    :timer.sleep(100)
    todo_id
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index todos" do
    setup do
      # Create diverse todos for sorting/filtering tests
      # Add a small buffer to 'today' to ensure it's slightly in the future
      due_date_today_future = DateTime.utc_now() |> DateTime.add(1, :second)
      due_date_plus_1 = DateTime.utc_now() |> DateTime.add(1, :day)
      due_date_plus_2 = DateTime.utc_now() |> DateTime.add(2, :day)

      # Todo A: name="Apple", due_date=+1 day, priority=low (default status: not_started)
      todo_a_id =
        create_todo_and_wait(%{
          name: "Apple",
          due_date: due_date_plus_1,
          priority: :low
        })

      # Todo B: name="Banana", due_date=+2 days, priority=medium (default status: not_started)
      todo_b_id =
        create_todo_and_wait(%{
          name: "Banana",
          due_date: due_date_plus_2,
          priority: :medium
        })

      # Todo C: name="Cherry", due_date=+0 days (today), priority=high (default status: not_started)
      todo_c_id =
        create_todo_and_wait(%{
          name: "Cherry",
          due_date: due_date_today_future, # Use the slightly future date
          priority: :high
        })

      # Update statuses after creation
      {:ok, _} = Todos.edit_todo(todo_b_id, %{status: :completed})
      # {:ok, _} = Todos.edit_todo(todo_c_id, %{status: :in_progress})?``/
      # Wait briefly for projections to update after edits
      :timer.sleep(100)

      {:ok,
       todo_ids: %{
         a: todo_a_id,
         b: todo_b_id,
         c: todo_c_id
       },
       due_dates: %{
         today: due_date_today_future,
         plus_1: due_date_plus_1,
         plus_2: due_date_plus_2
       }}
    end

    test "renders all todo items without filters", %{conn: conn, todo_ids: ids} do
      conn = get(conn, ~p"/api/todos")
      response = json_response(conn, 200)["data"]
      assert length(response) == 3 # Updated count

      response_ids = Enum.map(response, & &1["id"])
      assert ids.a in response_ids
      assert ids.b in response_ids
      assert ids.c in response_ids
    end

    test "filters todo items by status=not_started", %{conn: conn, todo_ids: ids} do
      conn = get(conn, ~p"/api/todos?status=not_started")
      response = json_response(conn, 200)["data"]
      assert length(response) == 2
      response_ids = Enum.map(response, & &1["id"])
      assert ids.a in response_ids
      assert ids.c in response_ids
    end

    test "filters todo items by status=completed", %{conn: conn, todo_ids: _ids} do
      conn = get(conn, ~p"/api/todos?status=completed")
      response = json_response(conn, 200)["data"]
      assert length(response) == 1
    end

    test "filters todo items by due_date", %{conn: conn, todo_ids: ids, due_dates: dates} do
      # Revert to standard ISO8601 format
      date_str = DateTime.to_iso8601(dates.today)
      conn = get(conn, ~p"/api/todos?due_date=#{date_str}")
      response = json_response(conn, 200)["data"]
      assert length(response) == 1
      response_ids = Enum.map(response, & &1["id"])
      assert ids.c in response_ids
    end

    test "filters todo items by status and due_date", %{
      conn: conn,
      todo_ids: ids,
      due_dates: dates
    } do
      # Revert to standard ISO8601 format
      date_str = DateTime.to_iso8601(dates.today)
      conn = get(conn, ~p"/api/todos?status=not_started&due_date=#{date_str}")
      response = json_response(conn, 200)["data"]
      assert length(response) == 1
      response_ids = Enum.map(response, & &1["id"])
      assert ids.c in response_ids
    end

    test "returns empty list for non-matching status", %{conn: conn} do
      # Use a valid but unassigned status
      conn = get(conn, ~p"/api/todos?status=in_progress")
      response = json_response(conn, 200)["data"]
      assert response == []
    end

    test "returns empty list for non-matching due_date", %{conn: conn} do
      date_str = DateTime.to_iso8601(~U[2024-12-31 23:59:59Z])
      conn = get(conn, ~p"/api/todos?due_date=#{date_str}")
      response = json_response(conn, 200)["data"]
      assert response == []
    end

    test "ignores invalid due_date format and returns all items", %{conn: conn} do
      # Expecting it to ignore the invalid date and return all 3 todos
      conn = get(conn, ~p"/api/todos?due_date=invalid-date-format")
      response = json_response(conn, 200)["data"]
      assert length(response) == 3 # Updated count
    end

    # --- Sorting Tests ---

    test "sorts todo items by due_date ascending", %{conn: conn, todo_ids: ids} do
      conn = get(conn, ~p"/api/todos?sort_by=due_date&sort_order=asc")
      response = json_response(conn, 200)["data"]
      response_ids = Enum.map(response, & &1["id"])
      assert response_ids == [ids.c, ids.a, ids.b]
    end

    test "sorts todo items by due_date descending", %{conn: conn, todo_ids: ids} do
      conn = get(conn, ~p"/api/todos?sort_by=due_date&sort_order=desc")
      response = json_response(conn, 200)["data"]
      response_ids = Enum.map(response, & &1["id"])
      assert response_ids == [ids.b, ids.a, ids.c]
    end

    test "sorts todo items by name ascending", %{conn: conn, todo_ids: ids} do
      conn = get(conn, ~p"/api/todos?sort_by=name&sort_order=asc")
      response = json_response(conn, 200)["data"]
      response_ids = Enum.map(response, & &1["id"])
      assert response_ids == [ids.a, ids.b, ids.c]
    end

    test "sorts todo items by name descending", %{conn: conn, todo_ids: ids} do
      conn = get(conn, ~p"/api/todos?sort_by=name&sort_order=desc")
      response = json_response(conn, 200)["data"]
      response_ids = Enum.map(response, & &1["id"])
      assert response_ids == [ids.c, ids.b, ids.a]
    end

    test "sorts todo items by status ascending", %{conn: conn, todo_ids: ids} do
      # Assuming alphabetical order for status strings: completed, in_progress, not_started
      conn = get(conn, ~p"/api/todos?sort_by=status&sort_order=asc")
      response = json_response(conn, 200)["data"]
      response_ids = Enum.map(response, & &1["id"])
      assert response_ids == [ids.b, ids.a, ids.c]
    end

    test "sorts todo items by status descending", %{conn: conn, todo_ids: ids} do
      conn = get(conn, ~p"/api/todos?sort_by=status&sort_order=desc")
      response = json_response(conn, 200)["data"]
      response_ids = Enum.map(response, & &1["id"])
      assert response_ids == [ids.a, ids.c, ids.b]
    end

    test "sorts todo items by priority ascending", %{conn: conn, todo_ids: ids} do
      # Assuming order: low, medium, high
      conn = get(conn, ~p"/api/todos?sort_by=priority&sort_order=asc")
      response = json_response(conn, 200)["data"]
      response_ids = Enum.map(response, & &1["id"])
      assert response_ids == [ids.a, ids.b, ids.c]
    end

    test "sorts todo items by priority descending", %{conn: conn, todo_ids: ids} do
      conn = get(conn, ~p"/api/todos?sort_by=priority&sort_order=desc")
      response = json_response(conn, 200)["data"]
      response_ids = Enum.map(response, & &1["id"])
      assert response_ids == [ids.c, ids.b, ids.a]
    end

    test "defaults to sorting by added_at ascending (implicitly)", %{conn: conn, todo_ids: ids} do
      # Assuming default sort is by insertion order (added_at asc)
      conn = get(conn, ~p"/api/todos")
      response = json_response(conn, 200)["data"]
      response_ids = Enum.map(response, & &1["id"])
      # The order depends on creation time, which setup defines as A, B, C
      assert response_ids == [ids.a, ids.b, ids.c]
    end
  end

  describe "create todo" do
    test "renders todo with minimal attributes", %{conn: conn} do
      attrs = %{name: "Test Todo"}

      conn = post(conn, ~p"/api/todos", todo: attrs)
      response = json_response(conn, 201)["data"]

      assert response["id"]
      assert response["name"] == "Test Todo"
      assert response["description"] == nil
      assert response["status"] == "not_started"
      assert response["due_date"] == nil
      assert response["added_at"]
      assert response["updated_at"]
      assert response["tags"] == []
    end

    test "renders todo with all attributes", %{conn: conn} do
      due_date_string = DateTime.utc_now() |> DateTime.add(1, :day) |> DateTime.to_iso8601()

      attrs = %{
        name: "Test Todo",
        description: "Test Description",
        due_date: due_date_string,
        tags: ["test1"],
        priority: "high"
      }

      conn = post(conn, ~p"/api/todos", todo: attrs)
      response = json_response(conn, 201)["data"]

      assert response["id"]
      assert response["name"] == "Test Todo"
      assert response["description"] == "Test Description"
      assert response["status"] == "not_started"
      assert response["due_date"] == due_date_string
      assert response["added_at"]
      assert response["updated_at"]
      assert response["tags"] == ["test1"]
      assert response["priority"] == "high"
    end

    test "renders error when name is missing", %{conn: conn} do
      attrs = %{name: nil}
      conn = post(conn, ~p"/api/todos", todo: attrs)
      assert json_response(conn, 422)["errors"] == %{"name" => ["Name is required"]}
    end

    test "renders error when name is too short", %{conn: conn} do
      attrs = %{name: "a"}
      conn = post(conn, ~p"/api/todos", todo: attrs)

      assert json_response(conn, 422)["errors"] == %{
               "name" => ["Name must be at least 2 characters"]
             }
    end

    test "renders error when due_date is in the past", %{conn: conn} do
      yesterday_due_date_string =
        DateTime.utc_now() |> DateTime.add(-1, :day) |> DateTime.to_iso8601()

      attrs = %{name: "Test Todo", due_date: yesterday_due_date_string}
      conn = post(conn, ~p"/api/todos", todo: attrs)

      assert json_response(conn, 422)["errors"] == %{
               "due_date" => ["Due date must be in the future"]
             }

      # assert json_response(conn, 201)["data"]["name"] == "Test Todo"
      # assert json_response(conn, 201)["data"]["status"] == "not_started" # Enum atoms are often returned as strings in JSON
    end
  end

  describe "show todo" do
    test "renders the specific todo item", %{conn: conn} do
      attrs = %{name: "Show Me", description: "This is the description"}
      todo_id = create_todo_and_wait(attrs)
      conn = get(conn, ~p"/api/todos/#{todo_id}")
      response = json_response(conn, 200)["data"]

      assert response["id"] == todo_id
      assert response["name"] == "Show Me"
      assert response["description"] == "This is the description"
      # Assuming default status
      assert response["status"] == "not_started"
      # Assuming nil if not provided
      assert response["due_date"] == nil
    end

    test "renders the specific todo item with all attribtutes", %{conn: conn} do

      due_date = DateTime.utc_now() |> DateTime.add(1, :day)
      due_date_string = due_date |> DateTime.to_iso8601()

      attrs = %{
        name: "Show Me",
        description: "This is the description",
        due_date: due_date,
        tags: ["test1"],
        priority: :high
      }

      todo_id = create_todo_and_wait(attrs)
      conn = get(conn, ~p"/api/todos/#{todo_id}")
      response = json_response(conn, 200)["data"]

      assert response["id"] == todo_id
      assert response["name"] == "Show Me"
      assert response["description"] == "This is the description"
      assert response["status"] == "not_started"
      assert response["due_date"] == due_date_string
      assert response["tags"] == ["test1"]
      assert response["priority"] == "high"
    end

    test "returns 404 when todo does not exist", %{conn: conn} do
      non_existent_id = Ecto.UUID.generate()
      conn = get(conn, ~p"/api/todos/#{non_existent_id}")
      assert response(conn, 404)
      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end
  end

  describe "edit todo" do
    setup do
      # Create a todo to be edited
      attrs = %{name: "Edit Me", description: "This is the description", priority: :high}
      todo_id = create_todo_and_wait(attrs)
      {:ok, todo_id: todo_id}
    end

    test "renders updated todo when data is valid", %{conn: conn, todo_id: id} do
      due_date_string = DateTime.utc_now() |> DateTime.add(3, :day) |> DateTime.to_iso8601()

      update_attrs = %{
        name: "Updated Name",
        description: "Updated Description",
        status: :completed,
        due_date: due_date_string,
        priority: "low"
      }

      conn = put(conn, ~p"/api/todos/#{id}", todo: update_attrs)
      response = json_response(conn, 200)["data"]

      assert response["id"] == id
      assert response["name"] == "Updated Name"
      assert response["description"] == "Updated Description"
      assert response["status"] == "completed"
      assert response["due_date"] == due_date_string
      assert response["priority"] == "low"
    end

    test "renders updated todo with partial data", %{conn: conn, todo_id: id} do
      update_attrs = %{name: "Just Updated Name"}

      conn = put(conn, ~p"/api/todos/#{id}", todo: update_attrs)
      response = json_response(conn, 200)["data"]

      assert response["id"] == id
      assert response["name"] == "Just Updated Name"
      # Original description
      assert response["description"] == "This is the description"
      # Original status
      assert response["status"] == "not_started"
      assert response["due_date"] == nil
      assert response["tags"] == []
    end

    test "redners updated todo with updaing tags only", %{conn: conn, todo_id: id} do
      update_attrs = %{tags: ["test1", "test2"]}
      conn = put(conn, ~p"/api/todos/#{id}", todo: update_attrs)
      response = json_response(conn, 200)["data"]
      assert response["tags"] == ["test1", "test2"]
      assert response["name"] == "Edit Me"
      assert response["description"] == "This is the description"
      assert response["status"] == "not_started"
      assert response["due_date"] == nil
    end

    test "renders error when name is too short on update", %{conn: conn, todo_id: id} do
      update_attrs = %{name: "a"}
      conn = put(conn, ~p"/api/todos/#{id}", todo: update_attrs)

      assert json_response(conn, 422)["errors"] == %{
               "name" => ["Name must be at least 2 characters"]
             }
    end

    test "renders error when due_date is in the past on update", %{conn: conn, todo_id: id} do
      yesterday_due_date_string =
        DateTime.utc_now() |> DateTime.add(-1, :day) |> DateTime.to_iso8601()

      update_attrs = %{due_date: yesterday_due_date_string}
      conn = put(conn, ~p"/api/todos/#{id}", todo: update_attrs)

      assert json_response(conn, 422)["errors"] == %{
               "due_date" => ["Due date must be in the future"]
             }
    end

    test "renders updated todo with only description", %{conn: conn, todo_id: id} do
      update_attrs = %{description: "Updated Description"}
      conn = put(conn, ~p"/api/todos/#{id}", todo: update_attrs)
      response = json_response(conn, 200)["data"]
      assert response["id"] == id
      assert response["name"] == "Edit Me"
      assert response["description"] == "Updated Description"
      assert response["status"] == "not_started"
      assert response["due_date"] == nil
    end

    test "renders updated todo with only status", %{conn: conn, todo_id: id} do
      update_attrs = %{status: :completed}
      conn = put(conn, ~p"/api/todos/#{id}", todo: update_attrs)
      response = json_response(conn, 200)["data"]
      assert response["id"] == id
      assert response["name"] == "Edit Me"
      assert response["description"] == "This is the description"
      assert response["status"] == "completed"
      assert response["due_date"] == nil
    end

    test "renders updated todo with only due_date", %{conn: conn, todo_id: id} do
      due_date_string = DateTime.utc_now() |> DateTime.add(3, :day) |> DateTime.to_iso8601()
      update_attrs = %{due_date: due_date_string}
      conn = put(conn, ~p"/api/todos/#{id}", todo: update_attrs)
      response = json_response(conn, 200)["data"]
      assert response["id"] == id
      assert response["name"] == "Edit Me"
      assert response["description"] == "This is the description"
      assert response["status"] == "not_started"
      assert response["due_date"] == due_date_string
    end

    test "returns 404 when trying to update non-existent todo", %{conn: conn} do
      non_existent_id = Ecto.UUID.generate()
      update_attrs = %{name: "Doesn't Matter"}
      conn = put(conn, ~p"/api/todos/#{non_existent_id}", todo: update_attrs)
      assert response(conn, 404)
      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end
  end

  describe "delete todo" do
    setup do
      attrs = %{name: "Delete Me", description: "This is the description"}
      todo_id = create_todo_and_wait(attrs)
      {:ok, todo_id: todo_id}
    end

    test "returns 204 No Content when data is valid", %{conn: conn, todo_id: todo_id} do
      conn = delete(conn, ~p"/api/todos/#{todo_id}")

      assert response(conn, 204) == ""

      # Verify the todo is actually gone from the read model perspective
      assert Todos.get_todo(todo_id) == nil
    end

    test "returns 404 Not Found when todo does not exist", %{conn: conn} do
      non_existent_uuid = Ecto.UUID.generate()
      conn = delete(conn, ~p"/api/todos/#{non_existent_uuid}")
      assert response(conn, 404)
      # Optionally check the body structure if you have a standard error format
      # assert json_response(conn, 404)["errors"] != nil
    end
  end
end

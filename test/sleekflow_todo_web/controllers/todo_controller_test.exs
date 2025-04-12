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
      # Create some todos with different statuses and due dates
      due_date_1 = DateTime.utc_now() |> DateTime.add(1, :day)
      due_date_2 = DateTime.utc_now() |> DateTime.add(2, :day)

      # Assuming add_todo defaults to not_started or handles string status correctly
      # We'll create one explicitly completed
      todo_id_not_started_1 = create_todo_and_wait(%{name: "Not Started 1", due_date: due_date_1}) # Default status
      todo_id_not_started_2 = create_todo_and_wait(%{name: "Not Started 2", due_date: due_date_2}) # Default status

      {:ok,
       todo_ids: %{
         not_started_1: todo_id_not_started_1,
         not_started_2: todo_id_not_started_2,
       },
       due_dates: %{
         date_1: due_date_1,
         date_2: due_date_2
       }}
    end

    test "renders all todo items without filters", %{conn: conn, todo_ids: ids} do
      conn = get(conn, ~p"/api/todos")
      response = json_response(conn, 200)["data"]
      assert length(response) == 2

      todo_ns1 = Enum.find(response, fn todo -> todo["id"] == ids.not_started_1 end)
      todo_ns2 = Enum.find(response, fn todo -> todo["id"] == ids.not_started_2 end)

      # Verify all todos exist
      assert todo_ns1 != nil
      assert todo_ns2 != nil

      # Verify names match
      assert todo_ns1["name"] == "Not Started 1"
      assert todo_ns2["name"] == "Not Started 2"

      # Verify statuses (assuming read model stores strings)
      assert todo_ns1["status"] == "not_started"
      assert todo_ns2["status"] == "not_started"
    end

    test "filters todo items by status=not_started", %{conn: conn, todo_ids: ids} do
      conn = get(conn, ~p"/api/todos?status=not_started")
      response = json_response(conn, 200)["data"]
      assert length(response) == 2
      response_ids = Enum.map(response, &(&1["id"]))
      assert ids.not_started_1 in response_ids
      assert ids.not_started_2 in response_ids
    end

    test "filters todo items by status=completed", %{conn: conn, todo_ids: _ids} do
      conn = get(conn, ~p"/api/todos?status=completed")
      response = json_response(conn, 200)["data"]
      assert length(response) == 0
    end

    test "filters todo items by due_date", %{conn: conn, todo_ids: ids, due_dates: dates} do
      date_str = DateTime.to_iso8601(dates.date_1)
      conn = get(conn, ~p"/api/todos?due_date=#{date_str}")
      response = json_response(conn, 200)["data"]
      assert length(response) == 1
      response_ids = Enum.map(response, &(&1["id"]))
      assert ids.not_started_1 in response_ids
      refute ids.not_started_2 in response_ids
    end

    test "filters todo items by status and due_date", %{conn: conn, todo_ids: ids, due_dates: dates} do
      date_str = DateTime.to_iso8601(dates.date_1)
      conn = get(conn, ~p"/api/todos?status=not_started&due_date=#{date_str}")
      response = json_response(conn, 200)["data"]
      assert length(response) == 1
      response_ids = Enum.map(response, &(&1["id"]))
      assert ids.not_started_1 in response_ids
      refute ids.not_started_2 in response_ids
    end

    test "returns empty list for non-matching status", %{conn: conn} do
      conn = get(conn, ~p"/api/todos?status=in_progress") # Use a valid but unassigned status
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
      assert length(response) == 2
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
    end

    test "renders todo with all attributes", %{conn: conn} do
      due_date_string = DateTime.utc_now() |> DateTime.add(1, :day) |> DateTime.to_iso8601()
      attrs = %{name: "Test Todo", description: "Test Description", due_date: due_date_string}
      conn = post(conn, ~p"/api/todos", todo: attrs)
      response = json_response(conn, 201)["data"]

      assert response["id"]
      assert response["name"] == "Test Todo"
      assert response["description"] == "Test Description"
      assert response["status"] == "not_started"
      assert response["due_date"] == due_date_string
      assert response["added_at"]
      assert response["updated_at"]
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
    setup do
      # Create a todo to be fetched
      attrs = %{name: "Show Me", description: "This is the description"}
      todo_id = create_todo_and_wait(attrs)
      {:ok, todo_id: todo_id}
    end

    test "renders the specific todo item", %{conn: conn, todo_id: id} do
      conn = get(conn, ~p"/api/todos/#{id}")
      response = json_response(conn, 200)["data"]

      assert response["id"] == id
      assert response["name"] == "Show Me"
      assert response["description"] == "This is the description"
      assert response["status"] == "not_started" # Assuming default status
      assert response["due_date"] == nil         # Assuming nil if not provided
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
      attrs = %{name: "Edit Me", description: "This is the description"}
      todo_id = create_todo_and_wait(attrs)
      {:ok, todo_id: todo_id}
    end

    test "renders updated todo when data is valid", %{conn: conn, todo_id: id} do
      due_date_string = DateTime.utc_now() |> DateTime.add(3, :day) |> DateTime.to_iso8601()
      update_attrs = %{
        name: "Updated Name",
        description: "Updated Description",
        status: :completed,
        due_date: due_date_string
      }

      conn = put(conn, ~p"/api/todos/#{id}", todo: update_attrs)
      response = json_response(conn, 200)["data"]

      assert response["id"] == id
      assert response["name"] == "Updated Name"
      assert response["description"] == "Updated Description"
      assert response["status"] == "completed"
      assert response["due_date"] == due_date_string
    end

    test "renders updated todo with partial data", %{conn: conn, todo_id: id} do
      update_attrs = %{name: "Just Updated Name"}

      conn = put(conn, ~p"/api/todos/#{id}", todo: update_attrs)
      response = json_response(conn, 200)["data"]

      assert response["id"] == id
      assert response["name"] == "Just Updated Name"
      assert response["description"] == "This is the description" # Original description
      assert response["status"] == "not_started" # Original status
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

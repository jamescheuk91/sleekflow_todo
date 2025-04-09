defmodule SleekFlowTodoWeb.TodoControllerTest do
  use SleekFlowTodoWeb.ConnCase, async: false

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index todos" do
    test "renders todo items", %{conn: conn} do
      todo_attr1 = %{name: "task one"}
      todo_attr2 = %{name: "task two"}
      # Create two todos
      {:ok, todo_id1} = SleekFlowTodo.Todos.add_todo(todo_attr1)
      {:ok,todo_id2} = SleekFlowTodo.Todos.add_todo(todo_attr2)

      # Make the request to get all todos
      conn = get(conn, ~p"/api/todos")

      # Assert the response
      response = json_response(conn, 200)["data"]
      |> IO.inspect()
      assert is_list(response)
      assert length(response) == 2

      # Extract todos with their names and IDs
      todo1 = Enum.find(response, fn todo -> todo["id"] == todo_id1 end)
      todo2 = Enum.find(response, fn todo -> todo["id"] == todo_id2 end)

      # Verify both todos exist
      assert todo1 != nil
      assert todo2 != nil

      # Verify names match with correct IDs (not mixed up)
      assert todo1["name"] == "task one"
      assert todo2["name"] == "task two"

    end
  end

  describe "create todo" do
    test "renders todo id", %{conn: conn} do
      attrs = %{name: "Test Todo"}

      conn = post(conn, ~p"/api/todos", todo: attrs)
      assert json_response(conn, 201)["data"]["id"]
      # assert json_response(conn, 201)["data"]["name"] == "Test Todo"
      # assert json_response(conn, 201)["data"]["status"] == "not_started" # Enum atoms are often returned as strings in JSON
    end

    test "renders error when name is missing", %{conn: conn} do
      attrs = %{}
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
end

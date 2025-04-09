defmodule SleekFlowTodoWeb.TodoControllerTest do
  use SleekFlowTodoWeb.ConnCase, async: false

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
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

defmodule SleekFlowTodoWeb.ErrorJSONTest do
  use SleekFlowTodoWeb.ConnCase
  test "renders 404" do
    assert SleekFlowTodoWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert SleekFlowTodoWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end

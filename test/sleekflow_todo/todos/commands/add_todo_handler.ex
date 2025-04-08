defmodule SleekFlowTodo.Todos.Commands.AddTodoHandlerTest do
  use ExUnit.Case

  alias SleekFlowTodo.Todos.Aggregates.Todo
  alias SleekFlowTodo.Todos.Commands.AddTodo
  alias SleekFlowTodo.Todos.Commands.AddTodoHandler
  alias SleekFlowTodo.Todos.Events.TodoAdded

  test "handle/2 AddTodo command" do
    todo_id = Commanded.UUID.uuid4()
    next_day = DateTime.add(DateTime.utc_now(), 1, :day)
    now = DateTime.utc_now()

    aggregate = %Todo{}

    command = %AddTodo{
      todo_id: todo_id,
      name: "Buy milk",
      description: "Buy milk description",
      due_date: next_day,
      added_at: now
    }

    assert {:ok, %TodoAdded{}} = AddTodoHandler.handle(aggregate, command)
  end
end

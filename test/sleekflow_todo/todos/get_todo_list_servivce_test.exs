defmodule SleekFlowTodo.Todos.GetTodoListServiceTest do
  use SleekFlowTodo.DataCase

  alias SleekFlowTodo.Todos.GetTodoListService
  alias SleekFlowTodo.Todos.TodoReadModel
  alias SleekFlowTodo.ProjectionRepo

  # Setup test data
  setup do
    now = DateTime.utc_now()
    due_date_1 = now |> DateTime.add(1, :day)
    due_date_2 = now |> DateTime.add(2, :day)

    # Insert test data
    todo1 =
      %TodoReadModel{
        id: Commanded.UUID.uuid4(),
        name: "Task A",
        description: "Description A",
        status: :not_started,
        due_date: due_date_1,
        added_at: now,
        updated_at: now
      }
      |> ProjectionRepo.insert!()

    todo2 =
      %TodoReadModel{
        id: Commanded.UUID.uuid4(),
        name: "Task B",
        description: "Description B",
        status: :completed,
        due_date: due_date_2,
        added_at: now
      }
      |> ProjectionRepo.insert!()

    todo3 =
      %TodoReadModel{
        id: Commanded.UUID.uuid4(),
        name: "Task C",
        description: "Description C",
        status: :not_started,
        due_date: nil,
        added_at: now
      }
      |> ProjectionRepo.insert!()


    # Return the created todos for potential use in tests, although we'll query them
    {:ok, todos: [todo1, todo2, todo3], due_dates: [due_date_1, due_date_2]}
  end

  describe "list_todos/1" do
    test "returns all todos sorted by name ascending by default" do
      todos = GetTodoListService.list_todos()
      assert length(todos) == 3
      assert Enum.map(todos, & &1.name) == ["Task A", "Task B", "Task C"]
    end

    test "filters todos by status" do
      todos = GetTodoListService.list_todos(filters: %{status: :not_started})
      assert length(todos) == 2
      assert Enum.all?(todos, &(&1.status == :not_started))
      # Default sort should still apply
      assert Enum.map(todos, & &1.name) == ["Task A", "Task C"]

      todos_empty = GetTodoListService.list_todos(filters: %{status: :in_progress})
      assert length(todos_empty) == 0
    end

    test "filters todos by due_date", %{due_dates: [due_date_1,_]} do
      todos = GetTodoListService.list_todos(filters: %{due_date: due_date_1})
      assert length(todos) == 1
      assert hd(todos).name == "Task A"
      assert hd(todos).due_date == due_date_1

      todos_empty = GetTodoListService.list_todos(filters: %{due_date: ~U[2023-01-01 00:00:00Z]})
      assert length(todos_empty) == 0
    end

    test "filters todos by status and due_date", %{due_dates: [due_date_1, _]} do
      todos =
        GetTodoListService.list_todos(
          filters: %{status: "not_started", due_date: due_date_1}
        )

      assert length(todos) == 1
      assert hd(todos).name == "Task A"

      todos_empty =
        GetTodoListService.list_todos(
          filters: %{status: "completed", due_date: ~U[2024-01-15 10:00:00Z]}
        )

      assert length(todos_empty) == 0
    end

    test "ignores invalid filter keys" do
      todos =
        GetTodoListService.list_todos(filters: %{invalid_key: "value", status: :not_started})

      # Should still filter by status correctly
      assert length(todos) == 2
      assert Enum.all?(todos, &(&1.status == :not_started))
      assert Enum.map(todos, & &1.name) == ["Task A", "Task C"]
    end

    test "ignores invalid filter value types" do
      # Invalid due_date type
      todos = GetTodoListService.list_todos(filters: %{due_date: "not a datetime"})
      # Filter ignored, returns all
      assert length(todos) == 3
      assert Enum.map(todos, & &1.name) == ["Task A", "Task B", "Task C"]

      # Invalid status type
      todos = GetTodoListService.list_todos(filters: %{status: :invalid_status})
      # Filter ignored, returns all
      assert length(todos) == 3
      assert Enum.map(todos, & &1.name) == ["Task A", "Task B", "Task C"]
    end

    test "sorts todos by name descending" do
      todos = GetTodoListService.list_todos(sort: %{field: :name, direction: :desc})
      assert length(todos) == 3
      assert Enum.map(todos, & &1.name) == ["Task C", "Task B", "Task A"]
    end

    test "sorts todos by status ascending" do
      todos = GetTodoListService.list_todos(sort: %{field: :status, direction: :asc})
      assert length(todos) == 3
      # completed comes before not_started alphabetically
      assert Enum.map(todos, & &1.status) == [:completed, :not_started, :not_started]
      # Check names within status groups (assuming default name asc secondary sort)
      assert Enum.map(todos, & &1.name) == ["Task B", "Task A", "Task C"]
    end

    test "sorts todos by status descending" do
      todos = GetTodoListService.list_todos(sort: %{field: :status, direction: :desc})
      assert length(todos) == 3
      assert Enum.map(todos, & &1.status) == [:not_started, :not_started, :completed]
      # Check names within status groups (assuming default name asc secondary sort)
      assert Enum.map(todos, & &1.name) == ["Task A", "Task C", "Task B"]
    end

    test "sorts todos by due_date ascending" do
      todos = GetTodoListService.list_todos(sort: %{field: :due_date, direction: :asc})
      assert length(todos) == 3
      # Corresponds to due dates 10th, 15th, 20th
      assert Enum.map(todos, & &1.name) == ["Task A", "Task B", "Task C"]
    end

    test "sorts todos by due_date descending" do
      todos = GetTodoListService.list_todos(sort: %{field: :due_date, direction: :desc})
      assert length(todos) == 3
      # Corresponds to due dates 20th, 15th, 10th
      assert Enum.map(todos, & &1.name) == ["Task C", "Task B", "Task A"]
    end

    test "applies default sort for invalid sort field" do
      todos = GetTodoListService.list_todos(sort: %{field: :invalid_field, direction: :asc})
      assert length(todos) == 3
      # Default name asc
      assert Enum.map(todos, & &1.name) == ["Task A", "Task B", "Task C"]
    end

    test "applies default sort for invalid sort direction" do
      todos = GetTodoListService.list_todos(sort: %{field: :name, direction: :invalid_direction})
      assert length(todos) == 3
      # Default name asc
      assert Enum.map(todos, & &1.name) == ["Task A", "Task B", "Task C"]
    end

    test "filters and sorts todos" do
      # Filter not_started, sort by due date descending
      todos =
        GetTodoListService.list_todos(
          filters: %{status: :not_started},
          sort: %{field: :due_date, direction: :desc}
        )

      assert length(todos) == 2
      assert Enum.all?(todos, &(&1.status == :not_started))
      # Due dates 20th, 15th
      assert Enum.map(todos, & &1.name) == ["Task C", "Task A"]
    end
  end
end

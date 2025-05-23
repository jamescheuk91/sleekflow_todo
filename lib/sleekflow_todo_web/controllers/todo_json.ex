defmodule SleekFlowTodoWeb.TodoJSON do
  alias SleekFlowTodo.Todos.TodoReadModel

  @doc """
  Renders a list of todos.
  """
  def index(%{todos: todos}) do
    %{data: for(todo <- todos, do: data(todo))}
  end

  @doc """
  Renders a single todo.
  """
  def show(%{todo: todo}) do
    %{data: data(todo)}
  end

  defp data(%TodoReadModel{} = todo) do
    %{
      id: todo.id,
      name: todo.name,
      description: todo.description,
      status: todo.status,
      priority: todo.priority,
      due_date: todo.due_date,
      added_at: todo.added_at,
      tags: todo.tags,
      updated_at: todo.updated_at
    }
  end
end

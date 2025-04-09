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
      due_date: todo.due_date
    }
  end
end

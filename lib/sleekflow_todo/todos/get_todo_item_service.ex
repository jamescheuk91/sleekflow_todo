defmodule SleekFlowTodo.Todos.GetTodoItemService do
  @moduledoc """
  Service for retrieving a single todo item by its ID from the read model.
  """

  alias SleekFlowTodo.Todos.TodoReadModel
  alias SleekFlowTodo.ProjectionRepo

  @doc """
  Retrieves a single todo item by its ID from the read model.

  Returns the `TodoReadModel` struct if found, otherwise `nil`.

  ## Examples

      iex> get_todo("valid-uuid")
      %TodoReadModel{}

      iex> get_todo("invalid-uuid")
      nil
  """
  def get_todo(id) do
    ProjectionRepo.get(TodoReadModel, id)
  end
end

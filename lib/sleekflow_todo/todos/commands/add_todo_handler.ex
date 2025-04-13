defmodule SleekFlowTodo.Todos.Commands.AddTodoHandler do
  @behaviour Commanded.Commands.Handler
  @moduledoc """
  Handler for the AddTodo command.
  """
  require Logger

  alias SleekFlowTodo.Todos.Aggregates.Todo
  alias SleekFlowTodo.Todos.Commands.AddTodo

  alias SleekFlowTodo.Todos.Validations.{
    DescriptionValidator,
    DueDateValidator,
    NameValidator,
    PriorityValidator,
    TagsValidator,
    Validation
  }

  def handle(aggregate, command) do
    Logger.debug("[AddTodoHandler] Received aggregate: #{inspect(aggregate)}")
    Logger.debug("[AddTodoHandler] Received command: #{inspect(command)}")

    validators = [
      &NameValidator.validate_name_required/1,
      &DescriptionValidator.validate_description_optional/1,
      &DueDateValidator.validate_due_date_optional/1,
      &TagsValidator.validate_tags_required_list/1,
      &PriorityValidator.validate_priority_optional/1
    ]

    case Validation.run_validators(command, validators) do
      :ok ->
        %AddTodo{
          todo_id: todo_id,
          name: name,
          description: description,
          due_date: due_date,
          priority: priority,
          tags: tags,
          added_at: added_at
        } = command

        result =
          Todo.add(aggregate, todo_id, name, description, due_date, priority, tags, added_at)

        {:ok, result}

      {:error, error_details} ->
        {:error, error_details}
    end
  end
end

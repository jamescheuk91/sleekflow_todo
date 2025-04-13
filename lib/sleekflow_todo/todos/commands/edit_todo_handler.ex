defmodule SleekFlowTodo.Todos.Commands.EditTodoHandler do
  @moduledoc """
  Handler for the EditTodo command.
  """

  require Logger

  alias SleekFlowTodo.Todos.Commands.EditTodo
  alias SleekFlowTodo.Todos.Aggregates.Todo
  alias SleekFlowTodo.Todos.Validations.{Validation, NameValidator, DescriptionValidator, DueDateValidator, StatusValidator, TagsValidator, PriorityValidator}

  def handle(aggregate, command) do
    Logger.debug("[EditTodoHandler] Received aggregate: #{inspect(aggregate)}")
    Logger.debug("[EditTodoHandler] Received command: #{inspect(command)}")

    validators = [
      &NameValidator.validate_name_optional/1,
      &DescriptionValidator.validate_description_optional/1,
      &DueDateValidator.validate_due_date_optional/1,
      &StatusValidator.validate_status_optional/1,
      &TagsValidator.validate_tags_optional_list/1,
      &PriorityValidator.validate_priority_optional/1
    ]

    case Validation.run_validators(command, validators) do
      :ok ->
        %EditTodo{
          todo_id: todo_id,
          name: name,
          description: description,
          due_date: due_date,
          status: status,
          priority: priority,
          tags: tags
        } = command

        result = Todo.edit(aggregate, todo_id, name, description, due_date, status, priority, tags)
        {:ok, result}

      {:error, error_details} ->
        {:error, error_details}
    end
  end
end

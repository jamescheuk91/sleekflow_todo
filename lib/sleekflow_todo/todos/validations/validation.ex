defmodule SleekFlowTodo.Todos.Validations.Validation do
  @moduledoc """
  Generic validation helper functions.
  """

  @type validator :: (map() -> :ok | {:error, {atom(), String.t()}})

  @doc """
  Runs a list of validator functions against the given parameters.

  Returns `:ok` if all validators pass.
  Returns `{:error, {field, message}}` for the first validation error.
  Returns `{:error, [{field, message}, ...]}` if multiple validators fail.
  """
  @spec run_validators(map(), [validator()]) ::
          :ok | {:error, {atom(), String.t()} | [{atom(), String.t()}]}
  def run_validators(params, validators) do
    errors =
      Enum.reduce(validators, [], fn validator, acc ->
        case validator.(params) do
          :ok ->
            acc

          {:error, reason} ->
            [reason | acc]
        end
      end)

    cond do
      Enum.empty?(errors) ->
        :ok

      length(errors) == 1 ->
        # Return the single error tuple directly
        {:error, hd(errors)}

      true ->
        # Reverse the list to maintain the order of validation checks for multiple errors
        {:error, Enum.reverse(errors)}
    end
  end
end

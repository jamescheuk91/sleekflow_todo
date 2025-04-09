defmodule SleekFlowTodo.Utils do
  @moduledoc """
  General utility functions for the SleekFlowTodo application.
  """

  @doc """
  Recursively converts string keys in a map to atoms.

  Uses `String.to_existing_atom/1` to prevent atom table overflow.
  Assumes the string keys correspond to atoms already known at runtime.

  ## Examples

      iex> map = %{"a" => 1, "b" => %{"c" => 3}, :d => 4}
      iex> SleekFlowTodo.Utils.key_to_atom(map)
      %{a: 1, b: %{c: 3}, d: 4}

      iex> map_with_unknown_key = %{"unknown_key" => 5}
      iex> SleekFlowTodo.Utils.key_to_atom(map_with_unknown_key)
      ** (ArgumentError) argument error

  """
  def key_to_atom(map) when is_map(map) do
    Enum.reduce(map, %{}, fn
      # String.to_existing_atom saves us from overloading the VM by
      # creating too many atoms. It'll always succeed because all the fields
      # in the database already exist as atoms at runtime.
      {key, value}, acc when is_atom(key) ->
        Map.put(acc, key, key_to_atom(value))

      {key, value}, acc when is_binary(key) ->
        Map.put(acc, String.to_existing_atom(key), key_to_atom(value))
    end)
  end

  # Handle non-map values (base case for recursion)
  def key_to_atom(value), do: value
end

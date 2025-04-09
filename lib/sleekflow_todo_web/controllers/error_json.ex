defmodule SleekFlowTodoWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  require Logger
  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".

  # Handle command validation errors passed as {field, message} tuples
  def render("error.json", %{reason: {field, message}})
      when is_atom(field) and is_binary(message) do
    Logger.error("Rendering validation error: #{field} - #{message}")
    %{errors: %{Atom.to_string(field) => [message]}}
  end

  def render(template, _assigns) do
    Logger.error("Rendering error template: #{template}")
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end

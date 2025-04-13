# lib/sleekflow_todo/activities/activity_feed_item_schema.ex
defmodule SleekFlowTodo.Activities.ActivityFeedItem do
  @moduledoc """
  Ecto schema representing an item in the activity feed read model.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "activity_feed_items" do
    field :todo_id, :binary_id
    # e.g., "todo_added", "todo_edited"
    field :type, :string
    # Map containing event-specific details
    field :details, :map
    field :occurred_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:todo_id, :type, :details, :occurred_at])
    |> validate_required([:todo_id, :type, :details, :occurred_at])
    |> foreign_key_constraint(:todo_id)
  end
end

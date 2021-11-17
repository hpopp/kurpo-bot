defmodule KurpoBot.Repo.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @required ~w(
    channel_id
    content
    guild_id
    message_id
    user_id
  )a

  schema "messages" do
    field :channel_id, :integer
    field :content, :string
    field :guild_id, :integer
    field :message_id, :integer
    field :user_id, :integer
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required)
    |> validate_required(@required)
  end
end

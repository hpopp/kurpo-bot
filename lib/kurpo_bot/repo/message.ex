defmodule KurpoBot.Repo.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @required ~w(
    channel_id
    content
    message_id
    user_id
  )a

  @params ~w(
    guild_id
  )a ++ @required

  schema "messages" do
    field :channel_id, :integer
    field :content, :string
    field :guild_id, :integer
    field :message_id, :integer
    field :user_id, :integer
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required)
  end
end

defmodule KurpoBot.Repo.Message do
  @moduledoc """
  Data model for persisted messages.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          __meta__: term(),
          channel_id: non_neg_integer | nil,
          content: binary | nil,
          guild_id: non_neg_integer | nil,
          id: non_neg_integer | nil,
          message_id: non_neg_integer | nil,
          user_id: non_neg_integer | nil
        }

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

  @doc """
  Ecto changeset for insert.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required)
    |> unique_constraint(:message_id)
  end
end

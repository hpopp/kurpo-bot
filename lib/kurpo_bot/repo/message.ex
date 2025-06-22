defmodule KurpoBot.Repo.Message do
  @moduledoc """
  Data model for persisted messages.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @derive {JSON.Encoder, except: [:__meta__]}

  @type id :: non_neg_integer()

  @typedoc """
  A message record.

  Fields:
  - `__meta__`: Ecto metadata
  - `channel_id`: ID of the channel the message was sent in
  - `content`: Content of the message
  - `guild_id`: ID of the guild the message was sent in
  - `id`: Unique identifier for the message
  - `message_id`: ID of the message in Discord
  - `user_id`: ID of the user who sent the message
  """
  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          channel_id: non_neg_integer() | nil,
          content: binary() | nil,
          guild_id: non_neg_integer() | nil,
          id: id() | nil,
          message_id: non_neg_integer() | nil,
          user_id: non_neg_integer() | nil
        }

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
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = model, params \\ %{}) do
    required = [:channel_id, :content, :message_id, :user_id]
    optional = [:guild_id]

    model
    |> cast(params, required ++ optional)
    |> validate_required(required)
    |> unique_constraint(:message_id)
  end
end

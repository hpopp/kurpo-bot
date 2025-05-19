defmodule KurpoBot.Repo.Channel do
  @moduledoc """
  Channel model
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias KurpoBot.Repo
  alias Nostrum.Api

  @type id :: non_neg_integer()

  @typedoc """
  A channel record.

  Fields:
  - `__meta__`: Ecto metadata
  - `channel_id`: Discord channel ID
  - `guild_id`: Discord guild ID
  - `id`: Unique identifier for the channel
  - `is_ignored`: Whether the channel is ignored
  """
  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          channel_id: non_neg_integer() | nil,
          guild_id: non_neg_integer() | nil,
          id: id() | nil,
          is_ignored: boolean()
        }

  schema "channels" do
    field :channel_id, :integer
    field :guild_id, :integer
    field :is_ignored, :boolean, default: false
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = model, params \\ %{}) do
    required = [:channel_id, :guild_id]
    optional = [:is_ignored]

    model
    |> cast(params, required ++ optional)
    |> validate_required(required)
    |> unique_constraint(:channel_id)
  end

  @spec get_or_insert(non_neg_integer()) :: t()
  def get_or_insert(channel_id) when is_integer(channel_id) and channel_id > 0 do
    case Repo.get_by(__MODULE__, channel_id: channel_id) do
      nil ->
        {:ok, %{guild_id: guild_id}} = Api.Channel.get(channel_id)
        channel = %{channel_id: channel_id, guild_id: guild_id}

        %__MODULE__{}
        |> changeset(channel)
        |> Repo.insert!()

      channel ->
        channel
    end
  end
end

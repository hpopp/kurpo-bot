defmodule KurpoBot.Repo.Channel do
  @moduledoc """
  Channel model
  """

  alias KurpoBot.Repo
  alias Nostrum.Api
  use Ecto.Schema
  import Ecto.Changeset

  @required ~w(
    channel_id
    guild_id
  )a

  @params ~w(
    is_ignored
  )a ++ @required

  schema "channels" do
    field :channel_id, :integer
    field :guild_id, :integer
    field :is_ignored, :boolean, default: false
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @params)
    |> validate_required(@required)
    |> unique_constraint(:channel_id)
  end

  def get_or_insert(channel_id) do
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

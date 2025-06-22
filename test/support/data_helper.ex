defmodule KurpoBot.DataHelper do
  @moduledoc false

  alias KurpoBot.Repo
  alias KurpoBot.Repo.{Channel, Message}

  @spec build(:channel | :message) :: Channel.t() | Message.t()
  def build(:channel) do
    %Channel{
      channel_id: :rand.uniform(1_000_000),
      guild_id: :rand.uniform(1_000_000)
    }
  end

  def build(:message) do
    %Message{
      channel_id: :rand.uniform(1_000_000),
      content: Faker.Lorem.sentence(),
      guild_id: :rand.uniform(1_000_000),
      message_id: :rand.uniform(1_000_000),
      user_id: :rand.uniform(1_000_000)
    }
  end

  @spec build(atom(), Keyword.t()) :: struct()
  def build(factory_name, attributes) do
    factory_name |> build() |> struct(attributes)
  end

  @spec insert!(atom(), Keyword.t()) :: struct() | no_return()
  def insert!(factory_name, attributes \\ []) do
    Repo.insert!(build(factory_name, attributes))
  end
end

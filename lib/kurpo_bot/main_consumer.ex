defmodule KurpoBot.MainConsumer do
  use Nostrum.Consumer

  alias KurpoBot.{MessageStore, Repo}
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    IO.inspect(msg)

    case msg.content do
      "!ping" ->
        Api.create_message(msg.channel_id, "Pong!")

      "!get" ->
        {:ok, message} = MessageStore.get_random()
        Api.create_message(msg.channel_id, message)

      "!sync" ->
        Api.create_message(msg.channel_id, "Syncing...")
        scrape_messages_by_user(msg.channel_id, KurpoBot.user_id())
        :ignore

      _ ->
        :ignore
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end

  def scrape_messages_by_user(channel_id, user_id) do
    case Api.get_channel_messages(channel_id, :infinity) do
      {:ok, messages} ->
        messages
        |> Enum.filter(fn msg -> msg.author.id == user_id end)
        |> Enum.filter(fn msg -> !String.starts_with?(msg.content, "!") end)
        |> Enum.map(fn x ->
          %{
            channel_id: x.channel_id,
            content: x.content,
            guild_id: x.guild_id,
            message_id: x.id,
            user_id: x.author.id
          }
        end)
        |> Enum.each(fn attrs ->
          %Repo.Message{}
          |> Repo.Message.changeset(attrs)
          |> Repo.insert()
        end)

      {:error, _} ->
        :ignore
    end
  end
end

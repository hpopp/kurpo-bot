defmodule KurpoBot.MainConsumer do
  use Nostrum.Consumer

  alias KurpoBot.MessageStore
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    IO.inspect(msg)

    case msg.content do
      "ping!" ->
        Api.create_message(msg.channel_id, "I copy and pasted this code")

      "!get" ->
        {:ok, message} = MessageStore.get_random()
        Api.create_message(msg.channel_id, message)

      "!become " <> user ->
        [username, discriminator] = String.split(user, "#")

        messages =
          Api.get_channel_messages(msg.channel_id, :infinity)
          |> elem(1)
          |> filter_by_user(username, discriminator)
          |> Enum.map(& &1.content)
          |> Enum.filter(fn s -> !String.starts_with?(s, "!") end)

        MessageStore.put_messages(messages)

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

  def filter_by_user(messages, username, discriminator) do
    Enum.filter(
      messages,
      &(&1.author.username == username && &1.author.discriminator == discriminator)
    )
  end
end

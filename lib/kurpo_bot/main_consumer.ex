defmodule KurpoBot.MainConsumer do
  use Nostrum.Consumer

  alias KurpoBot.Repo
  alias KurpoBot.Repo.Message
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
        message = Repo.get_random(Message)
        Api.create_message(msg.channel_id, message.content)

      "!sync" ->
        Api.create_message(msg.channel_id, "Syncing...")
        scrape_messages_by_user(msg.channel_id, KurpoBot.user_id())
        :ignore

      "!" <> _other ->
        # Ignore other commands
        :ignore

      _ ->
        cond do
          reply?(msg, KurpoBot.bot_id()) ->
            message = Repo.get_random(Message)
            Api.create_message(msg.channel_id, message.content)

          mentions?(msg, KurpoBot.bot_id()) ->
            message = Repo.get_random(Message)
            Api.create_message(msg.channel_id, message.content)

          msg.author.id == KurpoBot.user_id() ->
            save_message(msg)
        end

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

  def mentions?(message, user_id) do
    Enum.any?(message.mentions, fn m -> m.id == user_id end)
  end

  def reply?(%{referenced_message: nil}, _user_id) do
    false
  end

  def reply?(%{referenced_message: m}, user_id) do
    m.author.id == user_id
  end

  def save_message(message) do
    attrs = %{
      channel_id: message.channel_id,
      content: message.content,
      guild_id: message.guild_id,
      message_id: message.id,
      user_id: message.author.id
    }

    %Repo.Message{}
    |> Repo.Message.changeset(attrs)
    |> Repo.insert()
  end
end

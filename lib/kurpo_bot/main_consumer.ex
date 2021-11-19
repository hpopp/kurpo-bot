defmodule KurpoBot.MainConsumer do
  use Nostrum.Consumer

  alias KurpoBot.Handler.Stats
  alias KurpoBot.{MessageService, Repo}
  alias Nostrum.Api

  require Logger

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    msg |> inspect(pretty: true) |> Logger.debug()

    case msg.content do
      "!info" ->
        Stats.handle_project_info(msg.channel_id)

      "!statsu" ->
        Stats.handle_sysinfo(msg.channel_id)

      "!sync" ->
        if admin?(msg.author.id) do
          Api.create_message(msg.channel_id, "Starting sync...")
          scrape_messages_by_user(msg.channel_id, KurpoBot.user_id())
          Api.create_message(msg.channel_id, "Completed sync...")
        end

        :ignore

      "!" <> _other ->
        # Ignore other commands
        :ignore

      _ ->
        cond do
          reply?(msg, KurpoBot.bot_id()) ->
            message = MessageService.get_random(KurpoBot.user_id())
            type_and_send(msg.channel_id, message.content)

          mentions?(msg, KurpoBot.bot_id()) ->
            message = MessageService.get_random(KurpoBot.user_id())
            type_and_send(msg.channel_id, message.content)

          msg.author.id == KurpoBot.user_id() ->
            save_message(msg)

          true ->
            :ignore
        end
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end

  def type_and_send(channel_id, content) do
    5_000 |> :rand.uniform() |> Process.sleep()
    Api.start_typing(channel_id)
    5_000 |> :rand.uniform() |> Process.sleep()
    Api.create_message(channel_id, content)
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

      {:error, error} ->
        error |> inspect() |> Logger.error()
        :ignore
    end
  end

  def admin?(user_id) do
    user_id in KurpoBot.admin_ids()
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

defmodule KurpoBot.MainConsumer do
  @moduledoc """
  Primary Discord handler for incoming messages.

  This consumer does not run as a global singleton. If multiple replicas
  of the application are run, each will process the incoming message,
  resulting in multiple response messages by the bot.
  """

  use Nostrum.Consumer

  alias KurpoBot.Handler.Stats
  alias KurpoBot.{MessageService, Repo, Scraper}
  alias Nostrum.Api.{Channel, Message}

  require Logger

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Logger.metadata(author_id: msg.author.id, channel_id: msg.channel_id, guild_id: msg.guild_id)
    msg |> inspect(pretty: true) |> Logger.debug()

    case msg.content do
      "!info" ->
        Logger.info("Received !info.")
        Stats.handle_project_info(msg.channel_id)

      "!statsu" ->
        Logger.info("Received !statsu.")
        Stats.handle_sysinfo(msg.channel_id)

      "!sync" ->
        if admin?(msg.author.id) do
          Task.async(fn ->
            Logger.info("Started channel message sync.")
            Message.create(msg.channel_id, content: "Starting sync...")

            Scraper.sync_messages(msg.channel_id, KurpoBot.user_ids())

            Message.create(msg.channel_id, content: "Completed sync...")
            Logger.info("Completed channel message sync.")
          end)
        end

        :ignore

      "!" <> other ->
        Logger.warning("Ignoring !#{other} command.")
        :ignore

      _ ->
        default_handler(msg)
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end

  def default_handler(msg) do
    cond do
      mentions?(msg, KurpoBot.bot_id()) && storytime?(msg) ->
        for _ <- 1..5, do: do_random_reply(msg)
        Logger.info("Replied 5 random messages with storytime.")

      reply?(msg, KurpoBot.bot_id()) || mentions?(msg, KurpoBot.bot_id()) ->
        do_random_reply(msg)
        Logger.info("Replied with a random message.")

      msg.author.id in KurpoBot.user_ids() ->
        save_message(msg)

      true ->
        :ignore
    end
  end

  def do_random_reply(msg) do
    message =
      if ping?(msg) do
        MessageService.get_random_with_ping(KurpoBot.user_ids())
      else
        MessageService.get_random(KurpoBot.user_ids())
      end

    type_and_send(msg.channel_id, message.content)
  end

  def type_and_send(channel_id, content) do
    3_000 |> :rand.uniform() |> Process.sleep()
    Channel.start_typing(channel_id)

    t = round(String.length(content) / 6)
    Process.sleep(t * 1000)
    Message.create(channel_id, content: content)
  end

  def admin?(user_id) do
    user_id in KurpoBot.admin_ids()
  end

  def mentions?(message, user_id) when is_integer(user_id) do
    Enum.any?(message.mentions, fn m -> m.id == user_id end)
  end

  def mentions?(message, user_ids) when is_list(user_ids) do
    Enum.any?(message.mentions, fn m -> m.id in user_ids end)
  end

  def reply?(%{referenced_message: nil}, _user_ids) do
    false
  end

  def reply?(%{referenced_message: m}, user_id) when is_integer(user_id) do
    m.author.id == user_id
  end

  def reply?(%{referenced_message: m}, user_ids) when is_list(user_ids) do
    m.author.id in user_ids
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

  defp storytime?(msg) do
    msg.content
    |> String.downcase()
    |> String.contains?("storytime")
  end

  defp ping?(msg) do
    msg.content
    |> String.downcase()
    |> String.contains?("ping")
  end
end

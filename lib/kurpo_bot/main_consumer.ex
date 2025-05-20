defmodule KurpoBot.MainConsumer do
  @moduledoc """
  Primary Discord handler for incoming messages.

  This consumer does not run as a global singleton. If multiple replicas
  of the application are run, each will process the incoming message,
  resulting in multiple response messages by the bot.
  """

  use Nostrum.Consumer

  import KurpoBot.MessageUtil

  alias KurpoBot.Handler.Stats
  alias KurpoBot.{MessageService, Repo, Scraper}
  alias Nostrum.Api.{Channel, Message}

  require Logger

  @spec handle_event(Nostrum.Consumer.event()) :: any()
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
        if KurpoBot.admin?(msg.author.id) do
          Task.async(fn -> do_sync(msg.channel_id) end)
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

  @spec default_handler(Nostrum.Struct.Message.t()) :: :ignore
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

  @spec do_random_reply(Nostrum.Struct.Message.t()) ::
          {:ok, Nostrum.Struct.Message.t()} | Nostrum.Api.error()
  def do_random_reply(msg) do
    message =
      if ping?(msg) do
        MessageService.get_random_with_ping(KurpoBot.user_ids())
      else
        MessageService.get_random(KurpoBot.user_ids())
      end

    type_and_send(msg.channel_id, message.content)
  end

  @spec type_and_send(non_neg_integer(), String.t()) ::
          {:ok, Nostrum.Struct.Message.t()} | Nostrum.Api.error()
  def type_and_send(channel_id, content) do
    3_000 |> :rand.uniform() |> Process.sleep()
    Channel.start_typing(channel_id)

    t = round(String.length(content) / 6)
    Process.sleep(t * 1000)
    Message.create(channel_id, content: content)
  end

  @spec save_message(Nostrum.Struct.Message.t()) ::
          {:ok, Repo.Message.t()} | {:error, Ecto.Changeset.t()}
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

  @spec do_sync(non_neg_integer()) :: :ok
  defp do_sync(channel_id) when is_integer(channel_id) and channel_id >= 0 do
    Logger.info("Started channel message sync.")
    Message.create(channel_id, content: "Starting sync...")

    Scraper.sync_messages(channel_id, KurpoBot.user_ids())

    Message.create(channel_id, content: "Completed sync...")
    Logger.info("Completed channel message sync.")
  end
end

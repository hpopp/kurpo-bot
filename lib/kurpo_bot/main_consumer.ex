defmodule KurpoBot.MainConsumer do
  use Nostrum.Consumer

  alias KurpoBot.Handler.Stats
  alias KurpoBot.{MessageService, Repo, Scraper}
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
          Task.async(fn ->
            Api.create_message(msg.channel_id, "Starting sync...")
            Scraper.sync_messages(msg.channel_id, KurpoBot.user_ids())
            Api.create_message(msg.channel_id, "Completed sync...")
          end)
        end

        :ignore

      "!" <> _other ->
        # Ignore other commands
        :ignore

      _ ->
        cond do
          mentions?(msg, KurpoBot.bot_id()) && String.contains?(msg.content, "storytime") ->
            for _ <- 1..5 do
              message = MessageService.get_random(KurpoBot.user_ids())
              type_and_send(msg.channel_id, message.content)
            end

          reply?(msg, KurpoBot.bot_id()) ->
            message = MessageService.get_random(KurpoBot.user_ids())
            type_and_send(msg.channel_id, message.content)

          mentions?(msg, KurpoBot.bot_id()) ->
            message = MessageService.get_random(KurpoBot.user_ids())
            type_and_send(msg.channel_id, message.content)

          msg.author.id in KurpoBot.user_ids() ->
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
    3_000 |> :rand.uniform() |> Process.sleep()
    Api.start_typing(channel_id)

    t = round(String.length(content) / 6)
    Process.sleep(t * 1000)
    Api.create_message(channel_id, content)
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
end

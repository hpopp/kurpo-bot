defmodule KurpoBot.Scraper do
  alias KurpoBot.Repo
  alias Nostrum.Api
  require Logger

  @limit 100

  def sync_messages(channel_id, user_ids) do
    do_get_messages(channel_id, user_ids)
  end

  def do_get_messages(channel_id, user_ids) do
    do_get_messages(channel_id, user_ids, {})
  end

  def do_get_messages(channel_id, user_ids, locator) do
    case Api.get_channel_messages(channel_id, @limit, locator) do
      {:ok, []} ->
        Logger.info("Finished sync for channel #{channel_id}, users #{inspect(user_ids)}")
        :ok

      {:ok, messages} ->
        filter_and_save(messages, user_ids)
        next_id = List.last(messages).id
        do_get_messages(channel_id, user_ids, {:before, next_id})
        :ok

      {:error, %{status_code: 429, response: %{retry_after: retry_after}}} ->
        Process.sleep(retry_after + 500)
        do_get_messages(channel_id, user_ids, locator)
        :ok

      {:error, reason} ->
        reason |> inspect() |> Logger.error()
    end
  end

  def filter_and_save(messages, user_ids) do
    messages
    |> Enum.filter(fn msg -> msg.author.id in user_ids end)
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
  end
end

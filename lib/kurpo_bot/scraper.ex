defmodule KurpoBot.Scraper do
  @moduledoc """
  Synchronizes user channel messages to the database.

  This is useful when the bot is first added to a server to
  synchronize all past messages. It must be run on each channel
  individually with the `!sync` command.
  """

  alias KurpoBot.Repo
  alias Repo.Channel
  alias Nostrum.Api
  require Logger

  @limit 100

  @doc """
  Fetches and saves all messages on a channel authored by
  specific users.

  This iterates in pages of #{@limit} until all messages are scraped.
  Ratelimiting is handled internally by Nostrum.
  """
  @spec sync_messages(non_neg_integer, [non_neg_integer]) :: :ok
  def sync_messages(_channel_id, []) do
    :ok
  end

  def sync_messages(channel_id, user_ids) do
    do_get_messages(channel_id, user_ids)
  end

  @spec do_get_messages(non_neg_integer(), [non_neg_integer()]) :: :ok
  defp do_get_messages(channel_id, user_ids) do
    do_get_messages(channel_id, user_ids, {})
  end

  @spec do_get_messages(non_neg_integer(), [non_neg_integer()], any()) :: :ok
  defp do_get_messages(channel_id, user_ids, locator) do
    Logger.info("Getting messages for #{channel_id}")

    case Api.Channel.messages(channel_id, @limit, locator) do
      {:ok, []} ->
        Logger.info("Finished sync for channel #{channel_id}, users #{inspect(user_ids)}")
        :ok

      {:ok, messages} ->
        filter_and_save(messages, user_ids)
        next_id = List.last(messages).id
        do_get_messages(channel_id, user_ids, {:before, next_id})
        :ok

      {:error, reason} ->
        reason |> inspect() |> Logger.error()
    end
  end

  @spec filter_and_save([Nostrum.Struct.Message.t()], [non_neg_integer()]) :: :ok
  defp filter_and_save(messages, user_ids) do
    messages
    |> Enum.filter(fn msg -> valid_message?(msg, user_ids) end)
    |> Enum.map(fn x ->
      %{guild_id: guild_id} = fetch_guild(x.channel_id, x.guild_id)

      %{
        channel_id: x.channel_id,
        content: x.content,
        guild_id: guild_id,
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

  @spec valid_message?(Nostrum.Struct.Message.t(), [non_neg_integer()]) :: boolean()
  defp valid_message?(%Nostrum.Struct.Message{author: author, content: content}, user_ids) do
    author.id in user_ids and !String.starts_with?(content, "!")
  end

  @spec fetch_guild(non_neg_integer(), non_neg_integer() | nil) :: %{guild_id: non_neg_integer()}
  defp fetch_guild(channel_id, nil), do: Channel.get_or_insert(channel_id)
  defp fetch_guild(_channel_id, guild_id), do: %{guild_id: guild_id}
end

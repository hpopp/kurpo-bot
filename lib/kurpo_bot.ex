defmodule KurpoBot do
  @moduledoc """
  Documentation for `KurpoBot`.
  """

  @doc """
  Returns whether the given user ID is a configured admin.

  ## Examples

      # 2222 is a configured admin for test purposes
      iex> KurpoBot.admin?(2222)
      true

      iex> KurpoBot.admin?(1111)
      false
  """
  @spec admin?(non_neg_integer()) :: boolean()
  def admin?(user_id) when is_integer(user_id) and user_id >= 0 do
    user_id in admin_ids()
  end

  @doc """
  Returns the configured admin IDs.

  ## Examples

      iex> KurpoBot.admin_ids()
      [2222]
  """
  @spec admin_ids :: [integer()]
  def admin_ids do
    Application.get_env(:kurpo_bot, :admin_ids, [])
  end

  @doc """
  Returns the configured bot ID.

  ## Examples

      iex> KurpoBot.bot_id() > 0
      true
  """
  @spec bot_id :: non_neg_integer()
  def bot_id do
    Application.get_env(:kurpo_bot, :bot_id)
  end

  @doc """
  Returns the configured user IDs to save messages for.

  ## Examples

      iex> KurpoBot.user_ids()
      [1111]
  """
  @spec user_ids :: [integer()]
  def user_ids do
    Application.get_env(:kurpo_bot, :user_ids)
  end

  @doc """
  Returns the application's version.

  ## Examples

      iex> KurpoBot.version()
      "0.6.5"
  """
  @spec version :: String.t()
  def version do
    :kurpo_bot |> Application.spec(:vsn) |> to_string()
  end
end

defmodule KurpoBot do
  @moduledoc """
  Documentation for `KurpoBot`.
  """

  @spec admin_ids :: [integer()]
  def admin_ids do
    Application.get_env(:kurpo_bot, :admin_ids, [])
  end

  @spec bot_id :: integer()
  def bot_id do
    Application.get_env(:kurpo_bot, :bot_id)
  end

  @spec user_ids :: [integer()]
  def user_ids do
    Application.get_env(:kurpo_bot, :user_ids)
  end

  @spec version :: String.t()
  def version do
    :kurpo_bot |> Application.spec(:vsn) |> to_string()
  end
end

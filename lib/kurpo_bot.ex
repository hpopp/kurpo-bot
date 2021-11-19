defmodule KurpoBot do
  @moduledoc """
  Documentation for `KurpoBot`.
  """

  def admin_ids do
    Application.get_env(:kurpo_bot, :admin_ids, [])
  end

  def bot_id do
    Application.get_env(:kurpo_bot, :bot_id)
  end

  def user_id do
    Application.get_env(:kurpo_bot, :user_id)
  end
end

defmodule KurpoBot do
  @moduledoc """
  Documentation for `KurpoBot`.
  """

  def bot_id() do
    Application.get_env(:kurpo_bot, :bot_id)
  end

  def user_id() do
    Application.get_env(:kurpo_bot, :user_id)
  end
end

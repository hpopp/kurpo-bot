defmodule KurpoBot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KurpoBot.Repo,
      KurpoBot.MainConsumer,
      KurpoBot.MessageStore
    ]

    opts = [strategy: :one_for_one, name: KurpoBot.Supervisor]
    result = Supervisor.start_link(children, opts)

    initialize_bot_id()

    result
  end

  def initialize_bot_id do
    {:ok, bot_info} = Nostrum.Api.get_application_information()
    Application.put_env(:kurpo_bot, :bot_id, String.to_integer(bot_info.id))
  end
end

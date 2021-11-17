defmodule KurpoBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KurpoBot.Repo,
      KurpoBot.MainConsumer,
      KurpoBot.MessageStore
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KurpoBot.Supervisor]
    result = Supervisor.start_link(children, opts)
    {:ok, bot_info} = Nostrum.Api.get_application_information()
    Application.put_env(String.to_integer(bot_info.id))
    result
  end
end

defmodule KurpoBot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        KurpoBot.Repo,
        KurpoBot.MainConsumer,
        migrate_database(System.get_env("MIX_ENV")),
        tcp_healthcheck()
      ]
      |> Enum.filter(&(not is_nil(&1)))

    OpentelemetryEcto.setup([:kurpo_bot, :repo])

    opts = [strategy: :one_for_one, name: KurpoBot.Supervisor]
    result = Supervisor.start_link(children, opts)

    initialize_bot_id()

    result
  end

  def initialize_bot_id do
    {:ok, bot_info} = Nostrum.Api.Self.application_information()
    Application.put_env(:kurpo_bot, :bot_id, String.to_integer(bot_info.id))
  end

  @spec tcp_healthcheck :: {module(), [term()]} | nil
  defp tcp_healthcheck do
    case Application.get_env(:kurpo_bot, :healthcheck_port) do
      nil -> nil
      port -> {TcpHealthCheck, [port: port]}
    end
  end

  defp migrate_database("test"), do: nil
  defp migrate_database(_other), do: KurpoBot.Task.MigrateDatabase
end

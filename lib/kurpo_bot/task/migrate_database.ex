defmodule KurpoBot.Task.MigrateDatabase do
  @moduledoc """
  Executes pending database migrations.
  """

  use Task, restart: :transient
  require Logger

  @spec start_link(term()) :: {:ok, pid()}
  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  @spec run(term()) :: [integer()]
  def run(_arg) do
    Logger.info("Running database migrations...")
    path = Application.app_dir(:kurpo_bot, "priv/repo/migrations")
    Ecto.Migrator.run(KurpoBot.Repo, path, :up, all: true)
  end
end

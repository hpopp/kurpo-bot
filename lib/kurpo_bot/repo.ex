defmodule KurpoBot.Repo do
  use Ecto.Repo,
    adapter: Ecto.Adapters.Postgres,
    otp_app: :kurpo_bot
end

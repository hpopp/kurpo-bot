defmodule KurpoBot.Repo do
  use Ecto.Repo,
    adapter: Ecto.Adapters.Postgres,
    otp_app: :kurpo_bot

  import Ecto.Query

  def get_random(model) do
    model
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> one()
  end

  def total(query) do
    query
    |> select([m], count(m.id))
    |> one()
  end
end

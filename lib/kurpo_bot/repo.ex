defmodule KurpoBot.Repo do
  @moduledoc """
  Ecto repository for persistence.
  """

  use Ecto.Repo,
    adapter: Ecto.Adapters.Postgres,
    otp_app: :kurpo_bot

  import Ecto.Query

  @doc """
  Fetches a random record for given model.
  """
  @spec get_random(module) :: struct | nil
  def get_random(model) do
    model
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> one()
  end

  @doc """
  Returns a total count of items for given model.
  """
  @spec total(module) :: non_neg_integer
  def total(query) do
    query
    |> select([m], count(m.id))
    |> one()
  end
end

defmodule KurpoBot.Repo do
  @moduledoc """
  Ecto repository for persistence.
  """

  use Ecto.Repo,
    adapter: Ecto.Adapters.Postgres,
    otp_app: :kurpo_bot

  import Ecto.Query

  @doc """
  Returns a total count of items for given model.

  ## Examples

      iex> KurpoBot.Repo.total(KurpoBot.Repo.Message)
      0
  """
  @spec total(module) :: non_neg_integer
  def total(query) do
    query
    |> select([m], count(m.id))
    |> one()
  end
end

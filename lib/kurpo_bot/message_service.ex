defmodule KurpoBot.MessageService do
  import Ecto.Query
  alias KurpoBot.Repo
  alias KurpoBot.Repo.Message

  def get_random(user_id) do
    Message
    |> where([m], m.user_id == ^user_id)
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
  end

  def total(user_id) do
    Message
    |> where([m], m.user_id == ^user_id)
    |> select([m], count(m.id))
    |> Repo.one()
  end
end

defmodule KurpoBot.MessageService do
  import Ecto.Query
  alias KurpoBot.Repo
  alias KurpoBot.Repo.Message

  def get_random(user_ids) do
    IO.inspect(user_ids)

    Message
    |> where([m], m.user_id in ^user_ids)
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
  end

  def total(user_ids) do
    Message
    |> where([m], m.user_id in ^user_ids)
    |> select([m], count(m.id))
    |> Repo.one()
  end
end

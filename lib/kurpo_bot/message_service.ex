defmodule KurpoBot.MessageService do
  import Ecto.Query
  alias KurpoBot.Repo
  alias KurpoBot.Repo.Message

  def get_random(user_ids) do
    Message
    |> where([m], m.user_id in ^user_ids)
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
  end

  def get_random_with_ping(user_ids) do
    Message
    |> where([m], m.user_id in ^user_ids)
    |> where([m], ilike(m.content, ^"%\@%"))
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

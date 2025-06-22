defmodule KurpoBot.MessageService do
  @moduledoc """
  Provides random messages and total counts for given users.
  """

  import Ecto.Query
  alias KurpoBot.Repo
  alias KurpoBot.Repo.Message

  @doc """
  Fetches a random message from given users.
  """
  @spec get_random([non_neg_integer()]) :: KurpoBot.Repo.Message.t() | nil
  def get_random(user_ids) when is_list(user_ids) do
    Message
    |> where([m], m.user_id in ^user_ids)
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Fetches a random message from given users that includes
  a mention of another user.
  """
  @spec get_random_with_ping([non_neg_integer()]) :: KurpoBot.Repo.Message.t() | nil
  def get_random_with_ping(user_ids) when is_list(user_ids) do
    Message
    |> where([m], m.user_id in ^user_ids)
    |> where([m], ilike(m.content, ^"%\@%"))
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Returns total messages for given users.
  """
  @spec total([non_neg_integer()]) :: non_neg_integer()
  def total(user_ids) when is_list(user_ids) do
    Message
    |> where([m], m.user_id in ^user_ids)
    |> select([m], count(m.id))
    |> Repo.one()
  end
end

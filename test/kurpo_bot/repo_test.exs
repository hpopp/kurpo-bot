defmodule KurpoBot.RepoTest do
  use KurpoBot.DataCase

  alias KurpoBot.Repo
  alias KurpoBot.Repo.Message

  describe "total/1" do
    test "returns 0 when no records exist" do
      assert Repo.total(Message) == 0
    end

    test "returns correct count when records exist" do
      create_messages(3)
      assert Repo.total(Message) == 3
    end

    test "returns correct count after inserting more records" do
      create_messages(2)
      assert Repo.total(Message) == 2

      create_messages(4)
      assert Repo.total(Message) == 6
    end
  end

  @spec create_messages(non_neg_integer()) :: [Message.t()]
  defp create_messages(count) do
    for _ <- 1..count, do: insert!(:message)
  end
end

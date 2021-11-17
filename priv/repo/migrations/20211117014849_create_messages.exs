defmodule KurpoBot.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add(:channel_id, :bigint)
      add(:content, :text)
      add(:guild_id, :bigint)
      add(:message_id, :bigint)
      add(:user_id, :bigint)
    end
  end
end

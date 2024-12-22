defmodule KurpoBot.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add(:channel_id, :bigint)
      add(:guild_id, :bigint)
      add(:is_ignored, :boolean, default: false, null: false)
    end
  end
end

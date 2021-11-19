defmodule KurpoBot.Repo.Migrations.AddUniqueMessageIdToMessages do
  use Ecto.Migration

  def change do
    create(unique_index(:messages, [:message_id]))
  end
end

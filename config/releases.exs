import Config

config :logger, level: String.to_atom(System.get_env("LOG_LEVEL", "error"))

config :kurpo_bot,
  admin_ids:
    System.get_env("KURPO_ADMIN_IDS", "1234")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1),
  bot_id: 1234,
  user_id: String.to_integer(System.fetch_env!("KURPO_ID"))

config :kurpo_bot, KurpoBot.Repo, url: System.fetch_env!("DATABASE_URL")

config :nostrum,
  token: System.fetch_env!("KURPO_TOKEN"),
  num_shards: :auto

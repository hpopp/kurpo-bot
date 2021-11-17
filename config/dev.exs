import Config

config :kurpo_bot,
  bot_id: 1234,
  user_id: String.to_integer(System.get_env("KURPO_ID", "1234"))

config :kurpo_bot, KurpoBot.Repo,
  database: "kurpo_bot_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :nostrum,
  token: System.get_env("KURPO_TOKEN"),
  num_shards: :auto

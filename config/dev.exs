import Config

config :kurpo_bot, user_id: String.to_integer(System.get_env("KURPO_ID"))

config :kurpo_bot, KurpoBot.Repo,
  database: "kurpo_bot_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :nostrum,
  token: System.get_env("KURPO_TOKEN"),
  num_shards: :auto

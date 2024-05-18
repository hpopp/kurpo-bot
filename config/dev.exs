import Config

config :kurpo_bot,
  admin_ids:
    System.get_env("KURPO_ADMIN_IDS", "1234")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.uniq(),
  bot_id: 1234,
  user_ids:
    System.get_env("KURPO_IDS", "1234")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.uniq()

config :kurpo_bot, KurpoBot.Repo,
  database: "kurpo_bot_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :nostrum,
  token: System.get_env("KURPO_TOKEN"),
  num_shards: :auto

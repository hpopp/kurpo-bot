import Config

config :kurpo_bot,
  admin_ids: [2222],
  bot_id: 1234,
  user_ids: [1111]

config :kurpo_bot, KurpoBot.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("POSTGRES_DB") || "kurpo_bot_test",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2,
  username: System.get_env("POSTGRES_USER") || "postgres"

config :nostrum,
  token: System.get_env("KURPO_TOKEN"),
  num_shards: :auto

import Config

if config_env() == :prod do
  config :logger, level: String.to_atom(System.get_env("LOG_LEVEL", "error"))

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

  config :kurpo_bot, KurpoBot.Repo, url: System.fetch_env!("DATABASE_URL")

  config :nostrum,
    token: System.fetch_env!("KURPO_TOKEN"),
    num_shards: :auto

  if System.get_env("OTLP_ENDPOINT") do
    config :opentelemetry,
      span_processor: :batch,
      traces_exporter: :otlp

    config :opentelemetry_exporter,
      otlp_protocol: :http_protobuf,
      otlp_endpoint: System.get_env("OTLP_ENDPOINT")
  end
end

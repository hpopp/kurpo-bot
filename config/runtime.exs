import Config

if config_env() == :prod do
  config :logger, level: String.to_atom(System.get_env("LOG_LEVEL", "info"))

  config :kurpo_bot,
    admin_ids:
      System.get_env("KURPO_ADMIN_IDS", "1234")
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.uniq(),
    bot_id: 1234,
    healthcheck_port: "HEALTHCHECK_PORT" |> System.get_env("4321") |> String.to_integer(),
    user_ids:
      System.get_env("KURPO_IDS", "1234")
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.uniq()

  config :kurpo_bot, KurpoBot.Repo, url: System.fetch_env!("DATABASE_URL")

  case System.get_env("DATABASE_CACERTFILE") do
    nil ->
      :ok

    cacertfile ->
      db_hostname = System.get_env("DATABASE_HOSTNAME")

      config :kurpo_bot, KurpoBot.Repo,
        ssl: [
          cacertfile: cacertfile,
          certfile: System.get_env("DATABASE_CERTFILE"),
          customize_hostname_check: [
            match_fun: fn _ip, {_, dns_name} ->
              dns_name == to_charlist(db_hostname)
            end
          ],
          keyfile: System.get_env("DATABASE_KEYFILE"),
          verify: :verify_peer,
          verify_fun:
            {&:ssl_verify_hostname.verify_fun/3, [check_hostname: to_charlist(db_hostname)]},
          versions: [:"tlsv1.2"]
        ]
  end

  case System.get_env("GCP_PROJECT_ID") do
    nil ->
      :ok

    project_id ->
      version = :kurpo_bot |> Application.spec() |> Keyword.get(:vsn) |> to_string()

      opts = [
        metadata: :all,
        project_id: project_id,
        service_context: %{
          service: "kurpo-bot",
          version: version
        }
      ]

      config :logger, :default_handler, formatter: LoggerJSON.Formatters.GoogleCloud.new(opts)
  end

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

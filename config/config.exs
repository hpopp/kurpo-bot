import Config

# Put MIX_ENV into the system environment
System.put_env("MIX_ENV", to_string(Mix.env()))

config :kurpo_bot, ecto_repos: [KurpoBot.Repo]

config :nostrum,
  gateway_intents: [
    :direct_messages,
    :direct_message_reactions,
    :direct_message_typing,
    :guild_messages,
    :guild_message_reactions,
    :guild_message_typing,
    :message_content
  ]

config :opentelemetry, traces_exporter: :none

import_config "#{Mix.env()}.exs"

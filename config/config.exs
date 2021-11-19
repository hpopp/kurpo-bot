import Config

# Put MIX_ENV into the system environment
System.put_env("MIX_ENV", to_string(Mix.env()))

config :kurpo_bot, ecto_repos: [KurpoBot.Repo]

import_config "#{Mix.env()}.exs"

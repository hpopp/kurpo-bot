import Config

config :kurpo_bot, ecto_repos: [KurpoBot.Repo]

import_config "#{Mix.env()}.exs"

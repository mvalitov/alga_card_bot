# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :alga_card,
  ecto_repos: [AlgaCard.Repo]

import_config "#{Mix.env()}.exs"

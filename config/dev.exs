use Mix.Config

config :alga_card, AlgaCard.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "alga_card_dev",
  username: "marsel",
  password: "marsel",
  hostname: "172.17.0.2",
  port: 5432,
  timeout: 60000

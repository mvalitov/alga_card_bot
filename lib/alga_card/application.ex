defmodule AlgaCard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    :ets.new(:users_states, [:set, :public, :named_table])

    children = [
      AlgaCard.Repo,
      {Agala.Bot, AlgaCard.BotConfig.get()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AlgaCard.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

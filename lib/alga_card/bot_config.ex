defmodule AlgaCard.BotConfig do
  alias Agala.Provider.Telegram.Conn.ProviderParams

  def get do
    %Agala.BotParams{
      # You can use any string. It's using for sending message from specific bot in paragraph #6
      name: Application.get_env(:alga_card, :agala_telegram)[:name],
      provider: Agala.Provider.Telegram,
      # RequestHandler from paragraph #2
      handler: AlgaCard.RequestHandler,
      provider_params: %ProviderParams{
        # Token from paragraph #3
        token: Application.get_env(:alga_card, :agala_telegram)[:token],
        poll_timeout: :infinity,
        hackney_opts: [proxy: "127.0.0.1:8123"]
      }
    }
  end
end

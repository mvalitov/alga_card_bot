defmodule AlgaCard.MessageSender do
  @moduledoc """
  Module for sending messages to telegram
  """

  alias Agala.Provider.Telegram.Helpers
  alias Agala.Conn

  # Bot name just like in bot configuration from paragraph #4
  @bot_name Application.get_env(:alga_card, :agala_telegram)[:name]

  def answer(telegram_user_id, message, opts \\ []) do
    # Function for sending response to bot
    Agala.response_with(
      %Conn{}
      # You must explicitly specify bot name.
      |> Conn.send_to(@bot_name)
      # Helper function for telegram prpovider.
      |> Helpers.send_message(telegram_user_id, message, opts)
      # Fallback after successful request sending. Pass Agala.Conn.t of finished request.
      |> Conn.with_fallback(&message_fallback(&1))
      # It is not necessary to pass fallback. It's just mechanism to make feedback after sending message.
      # For example it is necessary to display that message has been delivered. Or there could become error or something else.
    )
  end

  defp message_fallback(
         %Conn{
           fallback: %{
             "result" => %{
               "from" => %{"first_name" => first_name, "id" => id, "is_bot" => is_bot},
               "text" => text
             }
           }
         } = _conn
       ) do
    bot_postfix = if is_bot, do: "Bot", else: ""
    IO.puts("\n#{first_name} #{bot_postfix} #{id} : #{text}")
    IO.puts("----> You have just sent message <----")
  end
end

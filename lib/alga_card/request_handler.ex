defmodule AlgaCard.RequestHandler do
  @moduledoc false

  # Add it in handler. It will allow you to use `chain` macro
  use Agala.Chain.Builder
  # Specify provider.
  use Agala.Provider.Telegram, :handler
  alias Agala.Conn
  alias AlgaCard.MessageSender
  alias AlgaCard.Processor
  require Logger

  # Chain macro. Works just like `plug` macro.
  # You can pass there module. Like here.
  chain(Agala.Provider.Telegram.Chain.Parser)
  # Module must
  # 1. Have one `init` method with specification `@spec init(opts :: Keyword.t) :: Keyword.t`. Options will be passed to `call` function.
  # 2. Have one `call` method with specification `@spec call(conn :: Agala.Conn.t, opts :: Keyword.t) :: Agala.Conn.t`. Attention! It must return `Agala.Conn.t` function for chaining.

  # Or you can pass there current module function name
  # Function must have specification `@spec call(conn :: Agala.Conn.t, opts :: Keyword.t) :: Agala.Conn.t`
  chain(:handle)
  chain(:second_handle)

  def handle(
        %Conn{request: %{message: %{text: text}}} = conn,
        _opts
      ) do
    Logger.debug("text message")
    IO.inspect(conn.request.message)

    case Processor.process(
           text,
           conn.request.message
         ) do
      [text: text] ->
        MessageSender.answer(conn.request.message.from.id, text)

      [replies: replies] ->
        Enum.each(replies, fn r ->
          MessageSender.answer(conn.request.message.from.id, r[:text],
            reply_markup: r[:reply_markup]
          )
        end)

      [reply: reply, markup: markup] ->
        MessageSender.answer(conn.request.message.from.id, reply, markup)
    end

    # MessageSender.answer(user_telegram_id, "test",
    #   reply_markup:
    #     Jason.encode!(%{
    #       inline_keyboard: [
    #         [%{text: "Some button text 1", callback_data: "1"}]
    #       ]
    #     })
    # )

    conn
  end

  def handle(
        %Conn{request: %{callback_query: query}} = conn,
        _opts
      ) do
    Logger.debug("callback_query")
    IO.inspect(conn.request.callback_query)

    case Processor.callback(
           conn.request.callback_query.data,
           query
         ) do
      [text: text] ->
        MessageSender.answer(conn.request.callback_query.from.id, text)

      [text: text, markup: markup] ->
        MessageSender.answer(conn.request.callback_query.from.id, text, markup)
    end

    # MessageSender.answer(user_telegram_id, "test",
    #   reply_markup:
    #     Jason.encode!(%{
    #       inline_keyboard: [
    #         [%{text: "Some button text 1", callback_data: "1"}]
    #       ]
    #     })
    # )

    conn
  end

  def second_handle(conn, _opts) do
    IO.puts("----> You have just received message <----")
    Conn.halt(conn)
  end
end

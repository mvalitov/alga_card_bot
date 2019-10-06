defmodule AlgaCard.Processor do
  alias AlgaCard.Cards
  alias AlgaCard.Users
  alias AlgaCard.Balance
  require Logger

  def process("/start", message) do
    case Users.get_user_by_telegram_id(message.from.id) do
      nil ->
        Users.create_user!(%{
          telegram_id: message.from.id,
          first_name: message.from.first_name,
          last_name: message.from.last_name,
          username: message.from.username
        })

        [
          text: create_start_msg()
        ]

      %Users.User{} = user ->
        create_cards_buttons(user)
    end
  end

  def process("/add_card", message) do
    user =
      case Users.get_user_by_telegram_id(message.from.id) do
        nil ->
          Users.create_user!(%{
            telegram_id: message.from.id,
            first_name: message.from.first_name,
            last_name: message.from.last_name,
            username: message.from.username
          })

        user ->
          user
      end

    :ets.insert(:users_states, {user.id, "/add_card"})
    [text: "Введите номер вашей карты в ответном сообщении:"]
  end

  def process("/delete", message) do
    user =
      case Users.get_user_by_telegram_id(message.from.id) do
        nil ->
          Users.create_user!(%{
            telegram_id: message.from.id,
            first_name: message.from.first_name,
            last_name: message.from.last_name,
            username: message.from.username
          })

        user ->
          user
      end

    case Cards.list_cards_for_user(user.id) do
      [] ->
        [text: "У Вас нет сохраненных карт. Для добавления нажмите /add_card"]

      cards ->
        reply =
          Enum.map(cards, fn card ->
            [
              text: card.number,
              reply_markup:
                Jason.encode!(%{
                  inline_keyboard: [[%{text: "Удалить", callback_data: "delete"}]]
                })
            ]
          end)

        [replies: reply]
    end
  end

  def process(text, message) do
    user =
      case Users.get_user_by_telegram_id(message.from.id) do
        nil ->
          Users.create_user!(%{
            telegram_id: message.from.id,
            first_name: message.from.first_name,
            last_name: message.from.last_name,
            username: message.from.username
          })

        user ->
          user
      end

    case :ets.lookup(:users_states, user.id) do
      # [{18162128, "/add_card"}] or []
      [{_id, "/add_card"}] ->
        :ets.delete(:users_states, user.id)

        case Cards.create_card(%{
               number: text,
               user_id: user.id
             }) do
          {:ok, _card} ->
            create_cards_buttons(user)

          {:error, changeset} ->
            case changeset.errors[:number] do
              {_text, [constraint: :unique, constraint_name: "cards_user_id_number_index"]} ->
                [text: "Карта с таким номером уже добавлена"]

              _ ->
                Logger.error(inspect(changeset))
                [text: create_error_msg()]
            end
        end

      [] ->
        get_balance(text)
    end
  end

  def create_cards_buttons(user) do
    case Cards.list_cards_for_user(user.id) do
      [] ->
        [text: "У Вас нет сохраненных карт. Для добавления нажмите /add_card"]

      cards ->
        markup = [
          reply_markup:
            Jason.encode!(%{
              keyboard:
                Enum.map(cards, fn card ->
                  [%{text: card.number}]
                end) ++ [[%{text: "/delete"}], [%{text: "/add_card"}]]
            })
        ]

        [
          reply: "Выберите действие(для запроса баланса нажмите на кнопку с номером карты)",
          markup: markup
        ]
    end
  end

  def create_start_msg() do
    "Привет! Я - бот, позволяющий проверить баланс транспортной карты Алга. \n Для начала, нужно добавить карту: /add_card"
  end

  def create_error_msg() do
    "Oops! Возникла ошибка, пожалуйста, повторите попытку позже"
  end

  def callback("balance", query) do
    get_balance(query.message.text)
  end

  defp get_balance(number) do
    case Balance.get(number) do
      {:ok, sum} -> [text: "Баланс карты #{number} равен #{sum}"]
      {:error, reason} -> [text: reason]
    end
  end

  def callback("delete", query) do
    user = Users.get_user_by_telegram_id!(query.from.id)

    case Cards.get_user_card_by_number(user.id, query.message.text) do
      card ->
        case Cards.delete_card(card) do
          {:ok, _} ->
            [
              text: "Карта успешно удалена. \n /start",
              markup: [
                reply_markup:
                  Jason.encode!(%{
                    remove_keyboard: true
                  })
              ]
            ]

          {:error, changeset} ->
            Logger.error(inspect(changeset))
            [text: create_error_msg()]
        end

      nil ->
        [text: "Карта с таким номером не найдена"]
    end
  end
end

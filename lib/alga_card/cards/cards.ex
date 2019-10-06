defmodule AlgaCard.Cards do
  alias AlgaCard.Cards.Card
  alias AlgaCard.Utils
  alias AlgaCard.Repo
  import Ecto.Query

  @spec create_card(any) :: any
  def create_card(args) do
    args = Utils.key_to_string(args)

    %Card{}
    |> Card.changeset(args)
    |> Repo.insert()
  end

  @spec get_card(any) :: any
  def get_card(id) do
    Repo.one(from(c in Card, where: c.id == ^id))
  end

  @spec get_card!(any) :: any
  def get_card!(id) do
    Repo.one!(from(c in Card, where: c.id == ^id))
  end

  def list_cards_for_user(user_id) do
    Repo.all(from(c in Card, where: c.user_id == ^user_id))
  end

  def get_user_card_by_number(user_id, number) do
    Repo.one(from(c in Card, where: c.user_id == ^user_id and c.number == ^number))
  end

  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end
end

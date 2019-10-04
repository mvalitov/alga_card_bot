defmodule AlgaCard.Cards.Card do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "cards" do
    field(:number, :string, null: false)
    belongs_to(:user, AlgaCard.Users.User)
  end

  def changeset(%Card{} = card, args \\ %{}) do
    card
    |> cast(args, [:number, :user_id])
    |> validate_required([:number_id, :user_id])
  end
end

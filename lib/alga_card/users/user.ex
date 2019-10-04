defmodule AlgaCard.Users.User do
  use Ecto.Schema
  alias __MODULE__
  import Ecto.Changeset

  schema "users" do
    field(:telegram_id, :integer)
    timestamps()
    has_many(:cards, AlgaCard.Cards.Card, on_delete: :delete_all)
  end

  def changeset(%User{} = user, args \\ %{}) do
    user
    |> cast(args, [:telegram_id])
    |> validate_required(:telegram_id)
  end
end

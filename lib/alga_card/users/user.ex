defmodule AlgaCard.Users.User do
  use Ecto.Schema
  alias __MODULE__
  import Ecto.Changeset

  schema "users" do
    field(:telegram_id, :integer)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:username, :string)
    timestamps()
    has_many(:cards, AlgaCard.Cards.Card, on_delete: :delete_all)
  end

  def changeset(%User{} = user, args \\ %{}) do
    user
    |> cast(args, [:telegram_id, :first_name, :last_name, :username])
    |> validate_required(:telegram_id)
  end
end

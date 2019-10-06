defmodule AlgaCard.Repo.Migrations.RemoveUniqueIndexCardNumber do
  use Ecto.Migration

  def change do
    drop(index(:cards, [:number]))
    create(unique_index(:cards, [:user_id, :number]))
  end
end

defmodule AlgaCard.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add(:number, :string, null: false)
      add(:user_id, references(:users, on_delete: :delete_all))
    end

    create(index(:users, [:telegram_id]))
    create(index(:cards, [:user_id]))
    create(unique_index(:cards, [:number]))
  end
end

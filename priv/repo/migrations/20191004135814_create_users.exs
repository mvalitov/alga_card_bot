defmodule AlgaCard.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:telegram_id, :integer, null: false)
      timestamps()
    end
  end
end

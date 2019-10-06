defmodule AlgaCard.Users do
  alias AlgaCard.Users.User
  alias AlgaCard.Utils
  alias AlgaCard.Repo
  import Ecto.Query

  @spec create_user!(any) :: any
  def create_user!(args) do
    args = Utils.key_to_string(args)

    %User{}
    |> User.changeset(args)
    |> Repo.insert!()
  end

  @spec get_user(any) :: any
  def get_user(id) do
    Repo.one(from(u in User, where: u.id == ^id))
  end

  @spec get_user!(any) :: any
  def get_user!(id) do
    Repo.one!(from(u in User, where: u.id == ^id))
  end

  @spec get_user_by_telegram_id(any) :: any
  def get_user_by_telegram_id(id) do
    Repo.one(from(u in User, where: u.telegram_id == ^id))
  end

  @spec get_user_by_telegram_id!(any) :: any
  def get_user_by_telegram_id!(id) do
    Repo.one!(from(u in User, where: u.telegram_id == ^id))
  end
end

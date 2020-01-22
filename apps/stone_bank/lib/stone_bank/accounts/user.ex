defmodule StoneBank.Accounts.User do
  @moduledoc """
    This scheme is a representation of the system user both admin and account owners.
    Only admin is allowed to see backoffice web pages.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias StoneBank.Accounts.Encryption
  alias StoneBank.Products.BankAccount

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string
    field :admin, :boolean, default: false
    has_many :banking_accounts, BankAccount

    timestamps()
  end

  @required ~w(name email encrypted_password admin)a

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required ++ [:password])
    |> downcase_email
    |> encrypt_password
    |> validate_required(@required)
    |> unique_constraint(:email)
  end

  defp encrypt_password(changeset) do
    password = get_change(changeset, :password)
    changeset = delete_change(changeset, :password)

    if password do
      encrypted_password = Encryption.hash_password(password)
      put_change(changeset, :encrypted_password, encrypted_password)
    else
      changeset
    end
  end

  defp downcase_email(%{changes: %{email: nil}} = changeset), do: changeset

  defp downcase_email(changeset), do: update_change(changeset, :email, &String.downcase/1)
end

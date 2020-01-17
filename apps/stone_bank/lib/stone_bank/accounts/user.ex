defmodule StoneBank.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias StoneBank.Products.BankAccount

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    has_many :banking_accounts, BankAccount

    timestamps()
  end

  @required ~w(name email password)a

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required)
    |> validate_required(@required)
  end
end

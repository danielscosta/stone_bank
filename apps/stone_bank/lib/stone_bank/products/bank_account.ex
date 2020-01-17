defmodule StoneBank.Products.BankAccount do
  use Ecto.Schema
  import Ecto.Changeset

  alias StoneBank.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bank_accounts" do
    field :balance, :integer
    belongs_to :user, User

    timestamps()
  end

  @required ~w(balance user_id)a

  @doc false
  def changeset(bank_account, attrs) do
    bank_account
    |> cast(attrs, @required)
    |> validate_required(@required)
  end
end

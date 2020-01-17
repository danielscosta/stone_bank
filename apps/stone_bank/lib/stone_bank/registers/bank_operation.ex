defmodule StoneBank.Registers.BankOperation do
  use Ecto.Schema
  import Ecto.Changeset

  alias StoneBank.Products.BankAccount

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bank_operations" do
    field :value, :integer
    field :type, :string
    belongs_to :bank_account, BankAccount
    belongs_to :bank_account_destiny, BankAccount

    timestamps()
  end

  @required ~w(value type bank_account_id)a
  @optional ~w(bank_account_destiny_id)a

  @doc false
  def changeset(bank_operation, attrs) do
    bank_operation
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:type, ~w(deposit transfer withdraw))
  end
end

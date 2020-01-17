defmodule StoneBank.Repo.Migrations.CreateBankOperations do
  use Ecto.Migration

  def change do
    create table(:bank_operations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :value, :integer
      add :type, :string
      add :bank_account_id, references(:bank_accounts, type: :binary_id)
      add :bank_account_destiny_id, references(:bank_accounts, type: :binary_id)

      timestamps()
    end

    create index(:bank_operations, [:bank_account_id])
    create index(:bank_operations, [:bank_account_destiny_id])
  end
end

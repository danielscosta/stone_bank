defmodule StoneBank.RegistersTest do
  use StoneBank.DataCase

  alias StoneBank.Accounts
  alias StoneBank.Products
  alias StoneBank.Registers

  describe "bank_operations" do
    alias StoneBank.Registers.BankOperation

    @valid_attrs %{value: 42, type: "deposit"}
    @invalid_attrs %{value: nil, type: nil}

    def bank_operation_fixture(attrs \\ %{}) do
      {:ok, user} =
        Accounts.create_user(%{email: "some email", name: "some name", password: "some password"})

      {:ok, bank_account} = Products.create_bank_account(%{balance: 42, user_id: user.id})

      {:ok, bank_operation} =
        attrs
        |> Map.put(:bank_account_id, bank_account.id)
        |> Enum.into(@valid_attrs)
        |> Registers.create_bank_operation()

      bank_operation
    end

    test "list_bank_operations/0 returns all bank_operations" do
      bank_operation = bank_operation_fixture()
      assert Registers.list_bank_operations() == [bank_operation]
    end

    test "list_bank_operations/0 returns filtered bank_operations" do
      bank_operation = bank_operation_fixture()

      assert Registers.list_bank_operations_between_dates(
               ~N[2020-01-01 14:00:00],
               ~N[2020-01-01 15:00:00]
             ) == []

      assert Registers.list_bank_operations_between_dates(
               ~N[2020-01-01 14:00:00],
               bank_operation.inserted_at
             ) == [bank_operation]
    end

    test "get_bank_operation!/1 returns the bank_operation with given id" do
      bank_operation = bank_operation_fixture()
      assert Registers.get_bank_operation!(bank_operation.id) == bank_operation
    end

    test "create_bank_operation/1 with valid data creates a bank_operation" do
      {:ok, user} =
        Accounts.create_user(%{email: "some email", name: "some name", password: "some password"})

      {:ok, bank_account} = Products.create_bank_account(%{balance: 42, user_id: user.id})

      assert {:ok, %BankOperation{} = bank_operation} =
               Registers.create_bank_operation(
                 Map.put(@valid_attrs, :bank_account_id, bank_account.id)
               )

      assert bank_operation.value == 42
    end

    test "create_bank_operation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Registers.create_bank_operation(@invalid_attrs)
    end

    test "change_bank_operation/1 returns a bank_operation changeset" do
      bank_operation = bank_operation_fixture()
      assert %Ecto.Changeset{} = Registers.change_bank_operation(bank_operation)
    end
  end
end

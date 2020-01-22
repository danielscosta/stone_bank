defmodule StoneBank.ProductsTest do
  use StoneBank.DataCase

  alias StoneBank.Accounts
  alias StoneBank.Products

  describe "bank_accounts" do
    alias StoneBank.Products.BankAccount

    @valid_attrs %{balance: 42}
    @invalid_attrs %{balance: nil}

    def bank_account_fixture(attrs \\ %{}) do
      {:ok, user} =
        Accounts.create_user(%{email: "some email", name: "some name", password: "some password"})

      {:ok, bank_account} =
        attrs
        |> Map.put(:user_id, user.id)
        |> Enum.into(@valid_attrs)
        |> Products.create_bank_account()

      bank_account
    end

    test "list_bank_account_user_id/1 returns user bank accounts" do
      bank_account = bank_account_fixture()
      user = Accounts.get_user_by_email!("some email")
      assert Products.list_bank_account_user_id(user.id) == [bank_account]
    end

    test "get_bank_account!/1 returns the bank_account with given id" do
      bank_account = bank_account_fixture()
      assert Products.get_bank_account!(bank_account.id) == bank_account
    end

    test "create_bank_account/1 with valid data creates a bank_account" do
      {:ok, user} =
        Accounts.create_user(%{email: "some email", name: "some name", password: "some password"})

      assert {:ok, %BankAccount{} = bank_account} =
               Products.create_bank_account(Map.put(@valid_attrs, :user_id, user.id))

      assert bank_account.balance == 42
    end

    test "create_bank_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_bank_account(@invalid_attrs)
    end

    test "deposit_bank_account/1 returns the bank_operation" do
      bank_account = bank_account_fixture()
      user = Accounts.get_user_by_email!("some email")

      assert {:ok, %{bank_operation: bank_operation}} =
               Products.deposit_bank_account(%{
                 value: 1_000,
                 bank_account_id: bank_account.id,
                 user_id: user.id
               })

      assert bank_operation.type == "deposit"
      assert bank_operation.value == 1_000
      assert bank_account.balance + 1_000 == Products.get_bank_account!(bank_account.id).balance
    end

    test "withdraw_bank_account/1 returns the bank_operation" do
      bank_account = bank_account_fixture()
      user = Accounts.get_user_by_email!("some email")

      assert {:ok, %{bank_operation: bank_operation}} =
               Products.withdraw_bank_account(%{
                 value: 40,
                 bank_account_id: bank_account.id,
                 user_id: user.id
               })

      assert bank_operation.type == "withdraw"
      assert bank_operation.value == 40
      assert bank_account.balance - 40 == Products.get_bank_account!(bank_account.id).balance
    end

    test "withdraw_bank_account/1 returns error" do
      bank_account = bank_account_fixture()
      user = Accounts.get_user_by_email!("some email")

      assert {:error, :bank_operation, nil, %{update_bank_account: 0}} =
               Products.withdraw_bank_account(%{
                 value: 44,
                 bank_account_id: bank_account.id,
                 user_id: user.id
               })

      assert bank_account.balance == Products.get_bank_account!(bank_account.id).balance
    end

    test "transfer_bank_account/1 returns the bank_operation" do
      bank_account = bank_account_fixture()
      user = Accounts.get_user_by_email!("some email")
      {:ok, another_bank_account} = Products.create_bank_account(%{balance: 42, user_id: user.id})

      assert {:ok, %{bank_operation: bank_operation}} =
               Products.transfer_bank_account(%{
                 value: 40,
                 bank_account_id: bank_account.id,
                 bank_account_destiny_id: another_bank_account.id,
                 user_id: user.id
               })

      assert bank_operation.type == "transfer"
      assert bank_operation.value == 40
      assert bank_account.balance - 40 == Products.get_bank_account!(bank_account.id).balance
    end

    test "transfer_bank_account/1 returns error" do
      bank_account = bank_account_fixture()
      user = Accounts.get_user_by_email!("some email")
      {:ok, another_bank_account} = Products.create_bank_account(%{balance: 42, user_id: user.id})

      assert {:error, :bank_operation, nil, %{update_bank_account: 0}} =
               Products.withdraw_bank_account(%{
                 value: 44,
                 bank_account_id: bank_account.id,
                 bank_account_destiny_id: another_bank_account.id,
                 user_id: user.id
               })

      assert bank_account.balance == Products.get_bank_account!(bank_account.id).balance
    end

    test "change_bank_account/1 returns a bank_account changeset" do
      bank_account = bank_account_fixture()
      assert %Ecto.Changeset{} = Products.change_bank_account(bank_account)
    end
  end
end

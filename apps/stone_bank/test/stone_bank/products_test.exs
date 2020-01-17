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

    test "change_bank_account/1 returns a bank_account changeset" do
      bank_account = bank_account_fixture()
      assert %Ecto.Changeset{} = Products.change_bank_account(bank_account)
    end
  end
end

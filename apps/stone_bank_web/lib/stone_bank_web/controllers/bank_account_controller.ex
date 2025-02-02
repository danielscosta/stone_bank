defmodule StoneBankWeb.BankAccountController do
  use StoneBankWeb, :controller
  alias StoneBank.Products
  alias StoneBank.Products.BankAccount

  action_fallback StoneBankWeb.FallbackController

  def index(conn, _params) do
    bank_accounts = Products.list_bank_account_user_id(get_session(conn, :current_user_id))
    render(conn, "index.json", bank_accounts: bank_accounts)
  end

  def create(conn, %{"bank_account" => %{"balance" => balance}}) do
    balance =
      if is_nil(balance) do
        nil
      else
        trunc(balance * 100)
      end

    with {:ok, %BankAccount{} = bank_account} <-
           Products.create_bank_account(
             %{}
             |> Map.put(:user_id, get_session(conn, :current_user_id))
             |> Map.put(:balance, balance)
           ) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.bank_account_path(conn, :show, bank_account))
      |> render("show.json", bank_account: bank_account)
    end
  end

  def show(conn, %{"id" => id}) do
    bank_account = Products.get_bank_account!(id)
    render(conn, "show.json", bank_account: bank_account)
  end

  alias StoneBank.Registers.BankOperation

  def deposit(conn, %{"id" => id, "value" => value}) do
    with {:ok, %{bank_operation: %BankOperation{}}} <-
           Products.deposit_bank_account(%{
             bank_account_id: id,
             user_id: get_session(conn, :current_user_id),
             value: trunc(value * 100)
           }) do
      bank_account = Products.get_bank_account!(id)
      render(conn, "show.json", bank_account: bank_account)
    end
  end

  def withdraw(conn, %{"id" => id, "value" => value}) do
    with {:ok, %{bank_operation: %BankOperation{}}} <-
           Products.withdraw_bank_account(%{
             bank_account_id: id,
             user_id: get_session(conn, :current_user_id),
             value: trunc(value * 100)
           }) do
      bank_account = Products.get_bank_account!(id)
      render(conn, "show.json", bank_account: bank_account)
    end
  end

  def transfer(conn, %{
        "id" => id,
        "bank_account_destiny_id" => bank_account_destiny_id,
        "value" => value
      }) do
    with {:ok, %{bank_operation: %BankOperation{}}} <-
           Products.transfer_bank_account(%{
             bank_account_id: id,
             user_id: get_session(conn, :current_user_id),
             bank_account_destiny_id: bank_account_destiny_id,
             value: trunc(value * 100)
           }) do
      bank_account = Products.get_bank_account!(id)
      render(conn, "show.json", bank_account: bank_account)
    end
  end
end

defmodule StoneBankWeb.BankAccountController do
  use StoneBankWeb, :controller

  alias StoneBank.Products
  alias StoneBank.Products.BankAccount

  action_fallback StoneBankWeb.FallbackController

  def create(conn, %{"bank_account" => bank_account_params}) do
    with {:ok, %BankAccount{} = bank_account} <- Products.create_bank_account(bank_account_params) do
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
    with {:ok, %{back_operation: %BankOperation{}}} <-
           Products.deposit_bank_account(%{
             back_account_id: id,
             value: value
           }) do
      bank_account = Products.get_bank_account!(id)
      render(conn, "show.json", bank_account: bank_account)
    end
  end

  def withdraw(conn, %{"id" => id, "value" => value}) do
    with {:ok, %{back_operation: %BankOperation{}}} <-
           Products.withdraw_bank_account(%{
             back_account_id: id,
             value: value
           }) do
      bank_account = Products.get_bank_account!(id)
      render(conn, "show.json", bank_account: bank_account)
    end
  end

  def transfer(conn, %{
        "id" => id,
        "back_account_destiny_id" => back_account_destiny_id,
        "value" => value
      }) do
    with {:ok, %{back_operation: %BankOperation{}}} <-
           Products.transfer_bank_account(%{
             back_account_id: id,
             back_account_destiny_id: back_account_destiny_id,
             value: value
           }) do
      bank_account = Products.get_bank_account!(id)
      render(conn, "show.json", bank_account: bank_account)
    end
  end
end

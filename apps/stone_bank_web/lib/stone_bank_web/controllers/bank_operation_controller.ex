defmodule StoneBankWeb.BankOperationController do
  use StoneBankWeb, :controller

  alias StoneBank.Registers

  def index(conn, _params) do
    bank_operations = Registers.list_bank_operations()
    render(conn, "index.html", bank_operations: bank_operations)
  end

  def show(conn, %{"id" => id}) do
    bank_operation = Registers.get_bank_operation!(id)
    render(conn, "show.html", bank_operation: bank_operation)
  end
end

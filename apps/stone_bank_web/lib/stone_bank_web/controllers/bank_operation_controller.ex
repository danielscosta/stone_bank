defmodule StoneBankWeb.BankOperationController do
  use StoneBankWeb, :controller

  alias StoneBank.Registers

  def index(conn, %{"filter" => %{"initial_date" => initial_date, "final_date" => final_date}}) do
    {:ok, initial_date} = Timex.parse("#{initial_date}:00+00:00", "{ISO:Extended}")
    {:ok, final_date} = Timex.parse("#{final_date}:00+00:00", "{ISO:Extended}")

    bank_operations =
      Registers.list_bank_operations_between_dates(
        DateTime.to_naive(initial_date),
        DateTime.to_naive(final_date)
      )

    render(conn, "index.html", bank_operations: bank_operations)
  end

  def index(conn, _params) do
    bank_operations = Registers.list_bank_operations()
    render(conn, "index.html", bank_operations: bank_operations)
  end
end

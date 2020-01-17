defmodule StoneBankWeb.BankAccountView do
  use StoneBankWeb, :view
  alias StoneBankWeb.BankAccountView

  def render("show.json", %{bank_account: bank_account}) do
    %{data: render_one(bank_account, BankAccountView, "bank_account.json")}
  end

  def render("bank_account.json", %{bank_account: bank_account}) do
    %{id: bank_account.id, balance: bank_account.balance}
  end
end

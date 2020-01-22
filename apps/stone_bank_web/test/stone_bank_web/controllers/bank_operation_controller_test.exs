defmodule StoneBankWeb.BankOperationControllerTest do
  use StoneBankWeb.ConnCase

  describe "index" do
    @tag :admin_authenticated
    test "lists all bank_operations", %{conn: conn} do
      conn = get(conn, Routes.bank_operation_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Bank operations"
    end
  end
end

defmodule StoneBankWeb.BankOperationControllerTest do
  use StoneBankWeb.ConnCase

  describe "index" do
    @tag :admin_authenticated
    test "lists all bank_operations", %{conn: conn} do
      conn = get(conn, Routes.bank_operation_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Bank operations"
    end

    @tag :admin_authenticated
    test "lists all bank_operations with filters", %{conn: conn} do
      conn =
        get(
          conn,
          Routes.bank_operation_path(conn, :index),
          filter: %{initial_date: "2020-01-01T14:00", final_date: "2020-01-01T14:00"}
        )

      assert html_response(conn, 200) =~ "Listing Bank operations"
    end
  end
end

defmodule StoneBankWeb.BankAccountControllerTest do
  use StoneBankWeb.ConnCase

  @create_attrs %{
    balance: 42
  }
  @invalid_attrs %{balance: nil}

  describe "create bank_account" do
    @tag :authenticated
    test "renders bank_account when data is valid", %{conn: conn} do
      conn = post(conn, Routes.bank_account_path(conn, :create), bank_account: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.bank_account_path(conn, :show, id))

      assert %{
               "id" => id,
               "balance" => 42.0
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.bank_account_path(conn, :create), bank_account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end

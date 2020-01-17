defmodule StoneBankWeb.BankAccountControllerTest do
  use StoneBankWeb.ConnCase

  alias StoneBank.Accounts

  @create_attrs %{
    balance: 42
  }
  @invalid_attrs %{balance: nil}

  describe "create bank_account" do
    test "renders bank_account when data is valid", %{conn: conn} do
      {:ok, user} =
        Accounts.create_user(%{email: "some email", name: "some name", password: "some password"})

      conn =
        post(conn, Routes.bank_account_path(conn, :create),
          bank_account: Map.put(@create_attrs, :user_id, user.id)
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.bank_account_path(conn, :show, id))

      assert %{
               "id" => id,
               "balance" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.bank_account_path(conn, :create), bank_account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end

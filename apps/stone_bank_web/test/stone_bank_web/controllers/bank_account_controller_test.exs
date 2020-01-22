defmodule StoneBankWeb.BankAccountControllerTest do
  use StoneBankWeb.ConnCase

  @create_attrs %{
    balance: 42
  }
  @invalid_attrs %{balance: nil}

  describe "create bank_account" do
    @tag :authenticated
    test "lists all bank_accounts", %{conn: conn} do
      conn = get(conn, Routes.bank_account_path(conn, :index))
      assert [] = json_response(conn, 200)["data"]
    end

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

    @tag :authenticated
    test "make a deposit in a bank_account", %{conn: conn} do
      conn = post(conn, Routes.bank_account_path(conn, :create), bank_account: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = put(conn, Routes.bank_account_path(conn, :deposit), %{value: 13.55, id: id})
      assert %{"balance" => balance} = json_response(conn, 200)["data"]
      assert balance == 55.55
    end

    @tag :authenticated
    test "make a withdraw in a bank_account", %{conn: conn} do
      conn = post(conn, Routes.bank_account_path(conn, :create), bank_account: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = put(conn, Routes.bank_account_path(conn, :withdraw), %{value: 42, id: id})
      assert %{"balance" => balance} = json_response(conn, 200)["data"]
      assert balance == 0
    end

    @tag :authenticated
    test "make a withdraw in a bank_account with insufficient balance", %{conn: conn} do
      conn = post(conn, Routes.bank_account_path(conn, :create), bank_account: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = put(conn, Routes.bank_account_path(conn, :withdraw), %{value: 45, id: id})
      assert response(conn, 422) =~ "Unprocessable Entity"
    end

    @tag :authenticated
    test "make a transfer in a bank_account", %{conn: conn} do
      conn = post(conn, Routes.bank_account_path(conn, :create), bank_account: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = post(conn, Routes.bank_account_path(conn, :create), bank_account: @create_attrs)

      assert %{"id" => another_id} = json_response(conn, 201)["data"]

      conn =
        put(conn, Routes.bank_account_path(conn, :transfer), %{
          value: 42,
          id: id,
          bank_account_destiny_id: another_id
        })

      assert %{"balance" => balance} = json_response(conn, 200)["data"]
      assert balance == 0
    end

    @tag :authenticated
    test "make a transfer in a bank_account with insufficient balance", %{conn: conn} do
      conn = post(conn, Routes.bank_account_path(conn, :create), bank_account: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = post(conn, Routes.bank_account_path(conn, :create), bank_account: @create_attrs)

      assert %{"id" => another_id} = json_response(conn, 201)["data"]

      conn =
        put(conn, Routes.bank_account_path(conn, :withdraw), %{
          value: 45,
          id: id,
          bank_account_destiny_id: another_id
        })

      assert response(conn, 422) =~ "Unprocessable Entity"
    end
  end
end

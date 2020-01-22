defmodule StoneBankWeb.PageControllerTest do
  use StoneBankWeb.ConnCase

  test "GET /login", %{conn: conn} do
    conn = get(conn, "/login")
    assert html_response(conn, 200) =~ "StoneBank"
  end

  alias StoneBank.Accounts

  test "POST /login", %{conn: conn} do
    {:ok, admin_user} =
      Accounts.create_user(%{
        email: "some admin mail",
        name: "some admin name",
        password: "some admin password",
        admin: true
      })

    conn = get(conn, "/login")
    assert html_response(conn, 200) =~ "StoneBank"

    conn =
      post(conn, "/login", %{
        "session" => %{"email" => admin_user.email, "password" => "some admin password"}
      })

    assert html_response(conn, 302) =~
             "<html><body>You are being <a href=\"/\">redirected</a>.</body></html>"
  end

  test "POST /login with wrong password", %{conn: conn} do
    {:ok, admin_user} =
      Accounts.create_user(%{
        email: "some admin mail",
        name: "some admin name",
        password: "some admin password",
        admin: true
      })

    conn = get(conn, "/login")
    assert html_response(conn, 200) =~ "StoneBank"

    conn =
      post(conn, "/login", %{
        "session" => %{"email" => admin_user.email, "password" => "another password"}
      })

    assert html_response(conn, 200) =~ "There was a problem with your username/password"
  end

  test "POST /api/login", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        email: "some mail",
        name: "some name",
        password: "some password"
      })

    conn =
      conn
      |> post("/api/login", %{
        "session" => %{"email" => user.email, "password" => "some password"}
      })

    assert html_response(conn, 302) =~
             "<html><body>You are being <a href=\"/api/bank_accounts\">redirected</a>.</body></html>"
  end

  test "POST /api/login with wrong password", %{conn: conn} do
    {:ok, user} =
      Accounts.create_user(%{
        email: "some mail",
        name: "some name",
        password: "some password"
      })

    conn =
      conn
      |> post("/api/login", %{
        "session" => %{"email" => user.email, "password" => "another password"}
      })

    assert response(conn, 403) =~
             "Forbidden"
  end
end

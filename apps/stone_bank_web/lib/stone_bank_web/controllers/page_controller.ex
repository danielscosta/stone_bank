defmodule StoneBankWeb.PageController do
  use StoneBankWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(%{request_path: "/login"} = conn, %{"session" => auth_params}) do
    case login(auth_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "Signed in successfully.")
        |> redirect(to: Routes.page_path(conn, :index))

      :error ->
        conn
        |> put_flash(:error, "There was a problem with your username/password")
        |> render("new.html")
    end
  end

  def create(%{request_path: "/api/login"} = conn, %{"session" => auth_params}) do
    case login(auth_params) do
      {:ok, user} ->
        {:ok, expires_at} =
          Timex.now() |> Timex.shift(minutes: +2) |> Timex.format("{ISO:Extended}")

        conn
        |> put_session(:current_user_id, user.id)
        |> put_session(:expires_at, expires_at)
        |> configure_session(renew: true)
        |> redirect(to: Routes.bank_account_path(conn, :index))

      :error ->
        conn
        |> put_status(:forbidden)
        |> put_view(StoneBankWeb.ErrorView)
        |> render(:"403")
    end
  end

  alias StoneBank.Accounts.Encryption

  defp login(%{"email" => email, "password" => password}) do
    user = StoneBank.Accounts.get_user_by_email!(String.downcase(email))

    case Encryption.validate_password(user, password) do
      true -> {:ok, user}
      _ -> :error
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user_id)
    |> put_flash(:info, "Signed out successfully.")
    |> redirect(to: Routes.page_path(conn, :new))
  end
end

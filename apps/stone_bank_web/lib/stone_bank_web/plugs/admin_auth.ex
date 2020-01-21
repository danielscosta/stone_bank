defmodule StoneBankWeb.Plugs.AdminAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias StoneBank.Accounts
  alias StoneBank.Accounts.User

  def init(opts), do: opts

  def call(conn, _opts) do
    with user_id <- Plug.Conn.get_session(conn, :current_user_id),
         false <- is_nil(user_id),
         %User{} = current_user <- Accounts.get_user!(user_id),
         true <- current_user.admin do
      conn
      |> assign(:current_user, current_user)
    else
      _ ->
        conn
        |> redirect(to: "/login")
        |> halt()
    end
  end
end

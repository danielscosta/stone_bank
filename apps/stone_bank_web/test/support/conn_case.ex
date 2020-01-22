# credo:disable-for-this-file
defmodule StoneBankWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use StoneBankWeb.ConnCase, async: true`, although
  this option is not recommendded for other databases.
  """

  use ExUnit.CaseTemplate
  use Phoenix.ConnTest

  # The default endpoint for testing
  @endpoint StoneBankWeb.Endpoint

  using do
    quote do
      # Import conveniences for testing with connections
      alias StoneBankWeb.Router.Helpers, as: Routes
      use Phoenix.ConnTest

      # The default endpoint for testing
      @endpoint StoneBankWeb.Endpoint
    end
  end

  alias StoneBank.Accounts

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(StoneBank.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(StoneBank.Repo, {:shared, self()})
    end

    conn =
      cond do
        tags[:admin_authenticated] == true ->
          {:ok, admin_user} =
            Accounts.create_user(%{
              email: "some admin mail",
              name: "some admin name",
              password: "some admin password",
              admin: true
            })

          build_conn()
          |> get("/login")
          |> post("/login", %{
            "session" => %{"email" => admin_user.email, "password" => "some admin password"}
          })

        tags[:authenticated] == true ->
          {:ok, user} =
            Accounts.create_user(%{
              email: "some mail",
              name: "some name",
              password: "some password"
            })

          build_conn()
          |> post("/api/login", %{
            "session" => %{"email" => user.email, "password" => "some password"}
          })

        true ->
          build_conn()
      end

    {:ok, conn: conn}
  end
end

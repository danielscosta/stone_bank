defmodule StoneBankWeb.Router do
  use StoneBankWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/", StoneBankWeb do
    pipe_through :browser

    get "/login", PageController, :new
    post "/login", PageController, :create
    resources "/users", UserController, only: [:new, :create, :show]
  end

  scope "/", StoneBankWeb do
    pipe_through [:browser, StoneBankWeb.Plugs.AdminAuth]

    get "/", PageController, :index
    delete "/", PageController, :delete
    resources "/users", UserController, only: [:index, :edit, :update, :delete]
    resources "/bank_operations", BankOperationController, only: [:index]
  end

  scope "/api", StoneBankWeb do
    pipe_through :api

    post "/login", PageController, :create
  end

  scope "/api", StoneBankWeb do
    pipe_through [:api, StoneBankWeb.Plugs.Auth]

    resources "/bank_accounts", BankAccountController, only: [:create, :show, :index]
    put "/bank_accounts/deposit", BankAccountController, :deposit
    put "/bank_accounts/withdraw", BankAccountController, :withdraw
    put "/bank_accounts/transfer", BankAccountController, :transfer
  end
end

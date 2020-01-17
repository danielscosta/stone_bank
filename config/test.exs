import Config

# Configure your database
config :stone_bank, StoneBank.Repo,
  username: "postgres",
  password: "postgres",
  database: "stone_bank_test",
  hostname: System.get_env("PG_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :stone_bank_web, StoneBankWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :bcrypt_elixir, :log_rounds, 4

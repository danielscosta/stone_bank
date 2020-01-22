import Config

config :stone_bank, StoneBank.Repo,
  hostname: System.get_env("PG_HOST"),
  username: System.get_env("PG_USERNAME") || "postgres",
  password: System.get_env("PG_PASSWORD") || "postgres",
  database: System.get_env("PG_DATABASE") || "stone_bank",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :stone_bank_web, StoneBankWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  server: true,
  secret_key_base:
    System.get_env("SECRET_KEY_BASE") ||
      "l3rgZ3jIqLBJVu4WMHPjIdzwwugJqBFIsQumIlXDmNjQoDp9zBlotPhO5z7NcY/6"

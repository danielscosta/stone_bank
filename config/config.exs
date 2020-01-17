import Config

# Configure Mix tasks and generators
config :stone_bank,
  ecto_repos: [StoneBank.Repo]

config :stone_bank_web,
  ecto_repos: [StoneBank.Repo],
  generators: [context_app: :stone_bank, binary_id: true]

# Configures the endpoint
config :stone_bank_web, StoneBankWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "l3rgZ3jIqLBJVu4WMHPjIdzwwugJqBFIsQumIlXDmNjQoDp9zBlotPhO5z7NcY/6",
  render_errors: [view: StoneBankWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: StoneBankWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

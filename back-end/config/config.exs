use Mix.Config

config :logger,
  level: :debug

config :ex_aws, :hackney_opts,
  follow_redirect: true,
  recv_timeout: 10_000

config :ex_aws, :retries,
  max_attempts: 10,
  base_backoff_in_ms: 10,
  max_backoff_in_ms: 10_000

config :ex_aws,
  debug_requests: true,
  region: "eu-central-1",
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}],
  security_token: [{:system, "AWS_SESSION_TOKEN"}]

config :ex_aws, :dynamodb,
  scheme: "https://",
  region: "eu-central-1"

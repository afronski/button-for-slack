~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  default_release: :button_for_slack_ex,
  default_environment: :lambda

environment :lambda do
  set include_erts: true
  set include_system_libs: true
  set include_src: false
  set strip_debug_info: true
  set cookie: :crypto.strong_rand_bytes(20) |> Base.encode16 |> String.to_atom
  set erl_opts: "-start_epmd false -epmd_module Elixir.EPMD.StubClient"
end

release :button_for_slack_ex do
  set version: current_version(:button_for_slack_ex)
  set applications: [
    :runtime_tools,
    :aws_lambda_elixir_runtime
  ]
end

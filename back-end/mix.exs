defmodule ButtonForSlackEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :button_for_slack_ex,
      version: "1.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_aws, "~> 2.1"},
      {:ex_aws_dynamo, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:aws_lambda_elixir_runtime,
       github: "patternmatch/aws-lambda-elixir-runtime",
       branch: "master",
       sparse: "elixir_runtime"},
      {:distillery, "~> 2.0"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false}
    ]
  end
end

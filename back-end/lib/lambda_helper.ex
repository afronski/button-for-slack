defmodule LambdaHelper do
  def response(body, status_code \\ 200, headers \\ %{}) do
    %{
      "statusCode" => status_code,
      "headers" => headers,
      "body" => Poison.encode!(body)
    }
  end

  def cors_response(body, status_code \\ 200) do
    %{
      "statusCode" => status_code,
      "headers" => %{
        "Access-Control-Allow-Origin" => System.get_env("CORS_ORIGIN"),
        "Access-Control-Allow-Methods" => "OPTIONS,PUT,POST,GET,DELETE",
        "Access-Control-Allow-Headers" =>
          "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Requested-With",
        "Access-Control-Allow-Credentials" => true
      },
      "body" => Poison.encode!(body)
    }
  end

  def table(:users), do: System.get_env("USERS_TABLE")
  def table(:workspaces), do: System.get_env("SLACK_WORKSPACES_TABLE")

  def get_user(request) do
    request["requestContext"]["authorizer"]["claims"]["cognito:username"]
  end
end

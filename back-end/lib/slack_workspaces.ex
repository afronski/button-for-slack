defmodule SlackWorkspaces do
  defmodule WorkspaceToken do
    @derive [ExAws.Dynamo.Encodable]
    @enforce_keys [:id, :token, :user_id, :team_id]
    defstruct [
      :id,
      :token,
      :user_id,
      :team_id,
      attributes: %{}
    ]
  end

  defmodule WorkspaceWithoutToken do
    @derive [ExAws.Dynamo.Encodable]
    @enforce_keys [:id, :token, :user_id, :team_id]
    defstruct [
      :id,
      :user_id,
      :team_id,
      attributes: %{}
    ]
  end

  alias ExAws.Dynamo
  alias ExAws.Request.Hackney

  def list_connected(request, context) when is_map(request) and is_map(context) do
    user_id = LambdaHelper.get_user(request)

    results = get_workspaces_for(user_id)

    LambdaHelper.cors_response(results)
  end

  def connect_new(request, context) when is_map(request) and is_map(context) do
    client_id = System.get_env("SLACK_CLIENT_ID")
    client_secret = System.get_env("SLACK_CLIENT_SECRET")

    code = request["queryStringParameters"]["code"]

    base_url = "https://slack.com/api/oauth.access"
    url = "#{base_url}?client_id=#{client_id}&client_secret=#{client_secret}&code=#{code}"

    [received_user_id, redirect_url] =
      request["queryStringParameters"]["state"]
      |> Base.decode64!()
      |> String.split(";")

    case Hackney.request("GET", url) do
      {:ok, %{status_code: 200, body: body}} ->
        response = Poison.decode!(body)
        save_workspace(received_user_id, response)

        LambdaHelper.response("Success!", 302, %{"Location" => redirect_url})

      {:error, reason} ->
        LambdaHelper.response("Error: #{reason}", 500)
    end
  end

  def disconnect(request, context) when is_map(request) and is_map(context) do
    user_id = LambdaHelper.get_user(request)

    [^user_id, team_id] =
      request["pathParameters"]["workspace_id"]
      |> Base.decode64!()
      |> String.split(";")

    delete_workspace(user_id, team_id)

    LambdaHelper.cors_response(%{
      "status" => "removed",
      "user_id" => user_id,
      "team_id" => team_id
    })
  end

  def get_workspaces_for(user_id) do
    user_id
    |> get_workspaces()
    |> Enum.map(fn item -> Dynamo.decode_item(item, as: WorkspaceWithoutToken) end)
  end

  def get_workspaces_with_token_for(user_id) do
    user_id
    |> get_workspaces()
    |> Enum.map(fn item -> Dynamo.decode_item(item, as: WorkspaceToken) end)
  end

  defp get_workspaces(user_id) do
    {:ok, results} =
      LambdaHelper.table(:workspaces)
      |> Dynamo.scan(
        filter_expression: "user_id = :uid",
        expression_attribute_values: [uid: user_id]
      )
      |> ExAws.request()

    results["Items"]
  end

  defp save_workspace(user_id, response) do
    team_id = response["team"]["id"]
    token = response["access_token"]

    attributes = %{
      name: response["team"]["name"],
      logo: response["team"]["image_44"]
    }

    workspace = %WorkspaceToken{
      id: "#{user_id};#{team_id}",
      token: token,
      user_id: user_id,
      team_id: team_id,
      attributes: attributes
    }

    LambdaHelper.table(:workspaces)
    |> Dynamo.put_item(workspace)
    |> ExAws.request()
  end

  defp delete_workspace(user_id, team_id) do
    LambdaHelper.table(:workspaces)
    |> Dynamo.delete_item(%{:id => "#{user_id};#{team_id}"})
    |> ExAws.request()
  end
end

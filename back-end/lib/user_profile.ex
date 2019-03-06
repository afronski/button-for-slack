defmodule UserProfile do
  defmodule Profile do
    @derive [ExAws.Dynamo.Encodable]
    @enforce_keys [:user_id]
    defstruct [
      :user_id,
      button: %{
        "device_id" => ""
      },
      statuses: %{
        "active" => "Working!",
        "active_emoji" => ":muscle:",
        "away" => "Away.",
        "away_emoji" => ":sleepy:"
      }
    ]
  end

  alias ExAws.Dynamo

  def fetch(request, context) when is_map(request) and is_map(context) do
    user_id = LambdaHelper.get_user(request)

    profile =
      case get_profile(user_id) do
        :not_found ->
          create_profile(user_id)

        result ->
          result
      end

    LambdaHelper.cors_response(profile)
  end

  def update(request, context) when is_map(request) and is_map(context) do
    user_id = LambdaHelper.get_user(request)

    body = Poison.decode!(request["body"])

    ^user_id = body["user_id"]
    button = body["button"]
    statuses = body["statuses"]

    profile = update_profile(user_id, button, statuses)

    LambdaHelper.cors_response(profile)
  end

  defp create_profile(user_id) do
    profile = %Profile{user_id: user_id}

    LambdaHelper.table(:users)
    |> Dynamo.put_item(profile)
    |> ExAws.request()

    profile
  end

  defp update_profile(user_id, button, statuses) do
    profile = %Profile{user_id: user_id, button: button, statuses: statuses}

    LambdaHelper.table(:users)
    |> Dynamo.put_item(profile)
    |> ExAws.request()

    profile
  end

  def get_profile_by_device(device_id) do
    result =
      LambdaHelper.table(:users)
      |> Dynamo.scan(
        filter_expression: "button.device_id = :did",
        expression_attribute_values: [did: device_id]
      )
      |> ExAws.request()

    case result do
      {:ok, empty} when map_size(empty) == 0 ->
        :not_found

      {:ok, results} ->
        case results["Items"] do
          [item] ->
            Dynamo.decode_item(item, as: Profile)

          _ ->
            :too_many
        end
    end
  end

  defp get_profile(user_id) do
    result =
      LambdaHelper.table(:users)
      |> Dynamo.get_item(%{user_id: user_id})
      |> ExAws.request()

    case result do
      {:ok, empty} when map_size(empty) == 0 ->
        :not_found

      {:ok, item} ->
        Dynamo.decode_item(item, as: Profile)
    end
  end
end

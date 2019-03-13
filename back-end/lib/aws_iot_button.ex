defmodule AwsIotButton do
  alias ExAws.Request.Hackney

  def handle_event(request, context) when is_map(request) and is_map(context) do
    type = request["clickType"]
    device_id = request["serialNumber"]

    case UserProfile.get_profile_by_device(device_id) do
      :not_found ->
        respond("Button #{device_id} is not claimed by any user.")

      :too_many ->
        respond("Button #{device_id} is claimed by more than one user.")

      profile ->
        user_id = profile.user_id
        workspaces = SlackWorkspaces.get_workspaces_with_token_for(user_id)

        results =
          workspaces
          |> Enum.map(fn workspace -> workspace.token end)
          |> Enum.map(fn token -> {change_status(type, profile, token), token} end)
          |> Enum.map(fn {status_result, token} -> {status_result, change_presence(type, token)} end)

        respond(
          "Action sent from button #{device_id} successfully accepted: #{Kernel.inspect(results)}"
        )
    end
  end

  defp change_status(type, profile, token) do
    url = "https://slack.com/api/users.profile.set"

    body =
      Poison.encode!(%{
        "profile" => %{
          "status_text" => text_by_type(type, profile),
          "status_emoji" => emoji_by_type(type, profile),
          "status_expiration" => 0
        }
      })

    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    response = Hackney.request("POST", url, body, headers)
    IO.puts("SLACK RESPONSE: #{Kernel.inspect(response)}")

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp change_presence(type, token) do
    url = "https://slack.com/api/users.setPresence"

    body =
      Poison.encode!(%{
        "presence" => presence_by_type(type)
      })

    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    response = Hackney.request("POST", url, body, headers)
    IO.puts("SLACK RESPONSE: #{Kernel.inspect(response)}")

    case response do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp presence_by_type("DOUBLE"), do: "away"
  defp presence_by_type(_),        do: "auto"

  defp text_by_type("SINGLE", profile), do: profile.statuses["active"]
  defp text_by_type("DOUBLE", profile), do: profile.statuses["away"]
  defp text_by_type("LONG", _profile),  do: ""

  defp emoji_by_type("SINGLE", profile), do: profile.statuses["active_emoji"]
  defp emoji_by_type("DOUBLE", profile), do: profile.statuses["away_emoji"]
  defp emoji_by_type("LONG", _profile),  do: ""

  defp respond(status) do
    IO.puts(status)

    %{"status" => status}
  end
end

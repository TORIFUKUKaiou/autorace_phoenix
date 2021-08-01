defmodule AutoracePhoenix.Autorace.GetEvents do
  def run do
    HTTPoison.get("https://admob-app-id-5452967350.firebaseio.com/events.json")
    |> handle_response()
    |> Map.get(:body)
    |> Jason.decode!()
    |> Enum.map(fn %{"start" => start, "end" => ending} = map ->
      Map.merge(map, %{"start" => from_unix(start), "end" => from_unix(ending)})
    end)
  end

  defp handle_response({:ok, %{status_code: 200} = response}), do: response

  defp handle_response({:ok, _response}), do: %{body: "[]"}

  defp handle_response({:error, _}), do: %{body: "[]"}

  defp from_unix(t) do
    dt = DateTime.from_unix!(div(t, 1000)) |> DateTime.add(60 * 60 * 9)
    DateTime.new!(DateTime.to_date(dt), DateTime.to_time(dt), "Japan", Zoneinfo.TimeZoneDatabase)
  end
end

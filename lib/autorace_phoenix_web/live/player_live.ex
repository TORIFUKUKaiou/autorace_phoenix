defmodule AutoracePhoenixWeb.PlayerLive do
  use AutoracePhoenixWeb, :live_view

  alias AutoracePhoenix.Autorace

  def mount(_params, _session, socket) do
    date = init_date() |> Date.to_string()

    {:ok,
     assign(socket,
       url: nil,
       index: -1,
       races: Autorace.races(),
       urls: nil
     )
     |> update_race_info(date, nil, "8")}
  end

  def render(assigns) do
    ~H"""
    <%= if @url == nil do %>
      <h1><%= @title %></h1>
      <h2><%= @range %></h2>

      <.form let={f} for={:race} phx-change="change" phx-submit="play">
        <label>
          Date: <%= date_input f, :date, value: @date %>
        </label>
        <label>
          Place: <%= select f, :place, @places, selected: @place %>
        </label>
        <label>
          Race: <%= select f, :race, @races, selected: @race %>
        </label>

        <%= submit "Play" %>
      </.form>

      <%= for race <- AutoracePhoenix.Autorace.Cache.events() |> Enum.reverse do %>
        <div
          phx-click={
            Phoenix.LiveView.JS.push("clicked",
            value: %{race: race})
          }
        >
          <p><%= Map.get(race, "range") %></p>
          <p><%= Map.get(race, "title") %></p>
          <p><%= Map.get(race, "place") %></p>
        </div>
      <% end %>
    <% else %>
      <button class="button is-link" phx-click="back">back</button>
      <%= live_component AutoracePhoenixWeb.PlayerComponent,
                         url: @url %>
    <% end %>
    """
  end

  def handle_event("change", params, socket) do
    %{"race" => %{"date" => date, "place" => place, "race" => race}} = params
    {:noreply, update_race_info(socket, date, place, race)}
  end

  def handle_event("clicked", %{"race" => %{"start" => start, "place" => place}}, socket) do
    race = socket.assigns.race |> Integer.to_string()
    date = start |> String.split("T") |> Enum.at(0)

    {:noreply, update_race_info(socket, date, place, race)}
  end

  def handle_event("play", _, socket) do
    index = socket.assigns.index + 1
    urls = urls(socket.assigns)
    {:noreply, assign(socket, urls: urls, url: Enum.at(urls, index), index: index)}
  end

  def handle_event("back", _, socket) do
    {:noreply, assign(socket, url: nil, index: -1)}
  end

  def handle_event("load-more", _, socket) do
    url = Enum.at(socket.assigns.urls, socket.assigns.index + 1)
    index = if url, do: socket.assigns.index + 1, else: -1
    {:noreply, assign(socket, url: url, index: index)}
  end

  defp urls(%{date: date, place: place, race: race}) do
    for i <- race..12 do
      Autorace.url(Date.from_iso8601!(date), place, i)
    end
  end

  defp init_date do
    dt = DateTime.now!("Japan", Zoneinfo.TimeZoneDatabase)

    if dt.hour < 17,
      do: DateTime.add(dt, -1 * 60 * 60 * 24, :second, Zoneinfo.TimeZoneDatabase),
      else: DateTime.to_date(dt)
  end

  defp places(date) do
    places =
      filtered_events(date)
      |> Enum.map(fn %{"place" => place} -> place end)
      |> Enum.map(&convert_place_value/1)

    result_places = Enum.filter(Autorace.places(), fn {_name, value} -> value in places end)

    if Enum.empty?(result_places), do: AutoracePhoenix.Autorace.places(), else: result_places
  end

  defp title_range(date, place) do
    map =
      filtered_events(date)
      |> Enum.find(fn event ->
        converted_place = Map.get(event, "place") |> convert_place_value()
        converted_place == place
      end)

    if map do
      {Map.get(map, "title"), Map.get(map, "range")}
    else
      {"開催無し", ""}
    end
  end

  defp filtered_events(date) do
    dt =
      DateTime.new!(
        Date.from_iso8601!(date),
        Time.new!(0, 0, 0, 0),
        "Japan",
        Zoneinfo.TimeZoneDatabase
      )

    AutoracePhoenix.Autorace.Cache.events()
    |> Enum.filter(fn %{"start" => start, "end" => ending} ->
      (DateTime.compare(dt, start) == :eq or DateTime.compare(dt, start) == :gt) and
        (DateTime.compare(dt, ending) == :eq or DateTime.compare(dt, ending) == :lt)
    end)
  end

  defp convert_place_value(place) do
    Map.get(%{"isesaki" => "isezaki", "hamamatsu" => "hama"}, place, place)
  end

  defp update_race_info(socket, date, place, race) do
    places = places(date)

    place =
      if Keyword.values(places) |> Enum.any?(&(&1 == place)),
        do: place,
        else: Keyword.values(places) |> Enum.at(0)

    {title, range} = title_range(date, place)

    assign(socket,
      places: places,
      date: date,
      place: place,
      title: title,
      range: range,
      race: String.to_integer(race)
    )
  end
end

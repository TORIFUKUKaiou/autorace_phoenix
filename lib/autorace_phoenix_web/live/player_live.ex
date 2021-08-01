defmodule AutoracePhoenixWeb.PlayerLive do
  use Surface.LiveView

  alias AutoracePhoenix.Autorace
  alias Surface.Components.Form
  alias Surface.Components.Form.{DateInput, Field, Label, Select}

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
    ~F"""
    {#if @url == nil}
    <div class="columns">
      <div class="column is-offset-one-quarter">
        <Form for={:race} change="change" opts={autocomplete: "off"}>
          <Field name="date">
            <Label/>
            <div class="control">
              <DateInput value={@date} />
            </div>
          </Field>
          <Field name="place">
            <Label/>
            <div class="select">
              <Select form="race" field="place" selected={@place} options={@places}/>
            </div>
          </Field>
          <Field name="race">
            <Label/>
            <div class="select">
              <Select form="race" field="race" selected={@race} options={@races}/>
            </div>
          </Field>
        </Form>
      </div>
      <div class="column">
        <Label>{@title}</Label>
        <p>{@range}</p>
        <button class="button is-link" phx-click="play">Play</button>
      </div>
    </div>
    {/if}

    {#if @url}
    <div class="column">
      <button class="button is-link" phx-click="back">back</button>
    </div>
    <AutoracePhoenixWeb.PlayerComponent url={@url} />
    {/if}
    """
  end

  def handle_event("change", params, socket) do
    %{"race" => %{"date" => date, "place" => place, "race" => race}} = params
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

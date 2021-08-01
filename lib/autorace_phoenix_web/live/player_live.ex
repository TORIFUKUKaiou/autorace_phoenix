defmodule AutoracePhoenixWeb.PlayerLive do
  use Surface.LiveView

  alias AutoracePhoenix.Autorace
  alias Surface.Components.Form
  alias Surface.Components.Form.{DateInput, Field, Label, Select}

  def mount(_params, _session, socket) do
    date = init_date()

    {:ok,
     assign(socket,
       url: nil,
       index: -1,
       date: Date.to_string(date),
       place: "kawaguchi",
       race: 8,
       places: Autorace.places(),
       races: Autorace.races(),
       urls: nil
     )}
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

    {:noreply,
     assign(socket,
       date: date,
       place: place,
       race: String.to_integer(race)
     )}
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
end

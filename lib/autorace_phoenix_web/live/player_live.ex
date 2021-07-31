defmodule AutoracePhoenixWeb.PlayerLive do
  use Surface.LiveView

  alias AutoracePhoenix.Autorace
  alias Surface.Components.Form
  alias Surface.Components.Form.{DateInput, Field, Label, Select}

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       url: nil,
       index: -1,
       date: Date.utc_today() |> Date.to_string(),
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

  def handle_event("load-more", _, socket) do
    index = socket.assigns.index + 1
    {:noreply, assign(socket, url: Enum.at(socket.assigns.urls, index), index: index)}
  end

  defp urls(%{date: date, place: place, race: race}) do
    for i <- race..12 do
      Autorace.url(Date.from_iso8601!(date), place, i)
    end
  end
end

defmodule AutoracePhoenixWeb.PlayerLive do
  use AutoracePhoenixWeb, :live_view

  @urls [
    "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
    "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
    "http://sp-auto.digi-c.com/autorace/_definst_/kawaguchi/2020/kawaguchi_20201103_11/playlist.m3u8",
    "http://sp-auto.digi-c.com/autorace/_definst_/kawaguchi/2020/kawaguchi_20201103_12/playlist.m3u8"
  ]

  def mount(_params, _session, socket) do
    {:ok, assign(socket, url: nil, index: -1)}
  end

  def render(assigns) do
    ~L"""
    <button phx-click="play">
      Play
    </button>

    <%= if @url do %>
    <%= live_component @socket, AutoracePhoenixWeb.PlayerComponent, url: @url %>
    <% end %>
    """
  end

  def handle_event("play", _, socket) do
    index = socket.assigns.index + 1
    {:noreply, assign(socket, url: Enum.at(@urls, index), index: index)}
  end

  def handle_event("load-more", _, socket) do
    index = socket.assigns.index + 1
    {:noreply, assign(socket, url: Enum.at(@urls, index), index: index)}
  end
end

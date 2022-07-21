defmodule AutoracePhoenixWeb.PlayerComponent do
  use AutoracePhoenixWeb, :live_component

  def render(assigns) do
    ~H"""
    <video id='video-id' phx-hook="Player">
      <source src={@url} type='application/x-mpegURL'/>
    </video>
    """
  end
end

defmodule AutoracePhoenixWeb.PlayerComponent do
  use AutoracePhoenixWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="pt-6"></div>
    <video id='video-id' phx-hook="Player">
      <source src={@url} type='application/x-mpegURL'/>
    </video>
    """
  end
end

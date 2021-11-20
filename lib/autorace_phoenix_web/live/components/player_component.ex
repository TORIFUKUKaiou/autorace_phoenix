defmodule AutoracePhoenixWeb.PlayerComponent do
  use AutoracePhoenixWeb, :live_component

  def render(assigns) do
    ~H"""
    <div id="dplayer"
         phx-hook="Player"
         data-url={@url} >
    </div>
    """
  end
end

defmodule AutoracePhoenixWeb.PlayerComponent do
  use AutoracePhoenixWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="dplayer"
         phx-hook="Player"
         data-url="<%= @url %>">
    </div>
    """
  end
end

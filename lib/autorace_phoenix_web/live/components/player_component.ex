defmodule AutoracePhoenixWeb.PlayerComponent do
  use Surface.Component

  prop url, :string, required: true

  def render(assigns) do
    ~F"""
    <div id="dplayer"
         phx-hook="Player"
         data-url={@url} >
    </div>
    """
  end
end

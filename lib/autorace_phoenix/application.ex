defmodule AutoracePhoenix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      AutoracePhoenix.Repo,
      # Start the Telemetry supervisor
      AutoracePhoenixWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: AutoracePhoenix.PubSub},
      # Start the Endpoint (http/https)
      AutoracePhoenixWeb.Endpoint,
      {AutoracePhoenix.Autorace.Cache, name: AutoracePhoenix.Autorace.Cache}
      # Start a worker by calling: AutoracePhoenix.Worker.start_link(arg)
      # {AutoracePhoenix.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AutoracePhoenix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AutoracePhoenixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

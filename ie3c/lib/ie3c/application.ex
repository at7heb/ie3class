defmodule Ie3c.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Ie3c.Repo,
      # Start the Telemetry supervisor
      Ie3cWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ie3c.PubSub},
      # Start the Endpoint (http/https)
      Ie3cWeb.Endpoint
      # Start a worker by calling: Ie3c.Worker.start_link(arg)
      # {Ie3c.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ie3c.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Ie3cWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

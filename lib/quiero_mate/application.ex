defmodule QuieroMate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      QuieroMateWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:quiero_mate, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: QuieroMate.PubSub},
      # Start a worker by calling: QuieroMate.Worker.start_link(arg)
      # {QuieroMate.Worker, arg},
      # Start to serve requests, typically the last entry
      QuieroMateWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QuieroMate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QuieroMateWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule JobsApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      JobsAppWeb.Telemetry,
      JobsApp.Repo,
      {DNSCluster, query: Application.get_env(:jobs_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: JobsApp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: JobsApp.Finch},
      # Start a worker by calling: JobsApp.Worker.start_link(arg)
      # {JobsApp.Worker, arg},
      # Start to serve requests, typically the last entry
      JobsAppWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: JobsApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JobsAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

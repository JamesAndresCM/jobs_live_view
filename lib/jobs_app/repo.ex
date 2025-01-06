defmodule JobsApp.Repo do
  use Ecto.Repo,
    otp_app: :jobs_app,
    adapter: Ecto.Adapters.Postgres
end

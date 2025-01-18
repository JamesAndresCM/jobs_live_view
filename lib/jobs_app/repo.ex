defmodule JobsApp.Repo do
  use Ecto.Repo,
    otp_app: :jobs_app,
    adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 10
end

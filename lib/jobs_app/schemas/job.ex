defmodule JobsApp.Schema.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :title, :string
    timestamps()
  end

  def changeset(job, params \\ %{}) do
    job
    |> cast(params, [:title])
    |> validate_required([:title])
  end
end

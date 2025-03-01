defmodule JobsApp.Schema.Job do
  use Ecto.Schema
  import Ecto.Changeset
  alias JobsApp.Schema.User

  schema "jobs" do
    belongs_to :user, User
    field :title, :string
    timestamps()
  end

  def changeset(job, params \\ %{}) do
    job
    |> cast(params, [:title])
    |> validate_required([:title])
    |> assoc_constraint(:user)
  end
end

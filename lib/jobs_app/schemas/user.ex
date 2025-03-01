defmodule JobsApp.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias JobsApp.Schema.UserToken
  alias JobsApp.Schema.Job

  schema "users" do
    has_many :jobs, Job
    has_many :tokens, UserToken
    field :email, :string
    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end

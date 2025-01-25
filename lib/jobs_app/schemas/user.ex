defmodule JobsApp.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
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

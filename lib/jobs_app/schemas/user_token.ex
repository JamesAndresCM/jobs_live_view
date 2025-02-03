defmodule JobsApp.Schema.UserToken do
  use Ecto.Schema

  alias JobsApp.Schema.User

  schema "user_tokens" do
    belongs_to :user, User
    field :token, :binary
    timestamps(updated_at: false)
  end
end

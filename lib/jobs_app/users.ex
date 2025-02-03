defmodule JobsApp.Users do
  alias JobsApp.Repo
  import Ecto.Query
  alias JobsApp.Schema.User
  alias JobsApp.Services.UserTokenService
  alias JobsApp.Mailers.UserMailer

  def save_user(attr) do
    if user = find_user(attr) do
      {:ok, user}
    else
      %User{}
      |> User.changeset(attr)
      |> Repo.insert()
    end
  end

  defp find_user(%{"email" => email}) do
    Repo.get_by(User, %{email: email})
  end

  defp find_user(_) do
    nil
  end

  def deliver_magic_link(user) do
    {email_token, user_token} = UserTokenService.build_hash_token(user)
    Repo.insert!(user_token)

    UserMailer.magic_link_email(user, email_token)
  end

  def get_all_tokens(user) do
    q = from u in User, preload: :tokens, where: u.id == ^user.id
    Repo.one(q)
  end
end

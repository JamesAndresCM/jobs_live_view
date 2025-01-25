defmodule JobsApp.Users do
  alias JobsApp.Repo
  alias JobsApp.Schema.User

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
end

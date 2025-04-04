defmodule JobsApp.UsersTest do
  use JobsApp.DataCase
  alias JobsApp.Users
  alias JobsApp.Repo
  alias JobsApp.Schema.User

  setup do
    {:ok, user} = Repo.insert(%User{email: "test@do.com"})
    {:ok, user: user}
  end

  describe "#find_user/1" do
    test "returns user when user exists", %{user: user} do
      assert Users.find_user(%{"email" => user.email}) == user
    end

    test "returns nil when user does not exist" do
      assert Users.find_user(%{email: "email"}) == nil
    end

    test "returns nil when not email provided" do
      assert Users.find_user(%{}) == nil
    end
  end
end
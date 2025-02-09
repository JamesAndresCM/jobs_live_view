defmodule JobsAppWeb.UserSessionsController do
  use JobsAppWeb, :controller
  alias JobsApp.Services.UserTokenService
  alias JobsApp.Schema.User

  def index(conn, %{"token" => token}) do
    case UserTokenService.get_user_by_token(token) do
      %User{} = user ->
        conn
        |> put_flash(:info, gettext("Bienvenido %{email}", email: user.email))
        |> put_token_in_session(token)
        |> redirect(to: ~p"/")

      result when result in [{:error}, nil] ->
        conn
        |> put_flash(:error, gettext("enlace no es valido"))
        |> redirect(to: ~p"/")
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_token)
    |> put_flash(:info, gettext("hasta pronto"))
    |> redirect(to: ~p"/")
  end

  defp put_token_in_session(conn, token) do
    put_session(conn, :user_token, token)
  end
end

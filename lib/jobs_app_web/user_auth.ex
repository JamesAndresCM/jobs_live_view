defmodule JobsAppWeb.UserAuth do
  use JobsAppWeb, :verified_routes
  alias JobsApp.Services.UserTokenService
  import Phoenix.Component, only: [assign_new: 3]
  import JobsAppWeb.Gettext
  import Plug.Conn

  def on_mount(:mount_current_user, _params, session, socket) do
    socket = assign_new(socket, :current_user, fn -> fetch_current_user(session) end)
    {:cont, socket}
  end

  def on_mount(:ensure_authenticated, _params, _session, socket) do
    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(
          :error,
          gettext("debes iniciar sesión para acceder a esta página")
        )
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  def redirect_if_user_is_authenticated(conn, _opts) do
    if get_session(conn, :user_token) do
      conn
      |> Phoenix.Controller.redirect(to: ~p"/")
      |> halt()
    else
      conn
    end
  end

  defp fetch_current_user(session) do
    if token = session["user_token"] do
      UserTokenService.get_user_by_token(token)
    end
  end
end

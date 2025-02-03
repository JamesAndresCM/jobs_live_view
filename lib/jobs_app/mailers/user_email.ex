defmodule JobsApp.Mailers.UserMailer do
  import Swoosh.Email
  alias JobsApp.Mailer

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"JobsApp", "no-reply@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _} = Mailer.deliver(email) do
      {:ok, recipient}
    end
  end

  def magic_link_email(user, login_url) do
    deliver(
      user.email,
      "Enlace para ingresar",
      """
      Hola #{user.email}

      Para ingresar a la aplicacion sigue el siguiente enlace 
      #{login_url}
      """
    )
  end
end

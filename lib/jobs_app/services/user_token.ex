defmodule JobsApp.Services.UserTokenService do
  alias JobsApp.Schema.UserToken
  alias JobsApp.Users
  @rand_size 32
  @hash_algorithm :sha256
  def build_hash_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {
      Base.url_encode64(token, padding: false),
      %UserToken{
        user_id: user.id,
        token: hashed_token
      }
    }
  end

  def get_user_by_token(token) do
    case decode_token(token) do
      {:ok, token} -> Users.get_by_session_token(token)
      {:error, _} -> nil
    end
  end

  defp decode_token(token) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        {:ok, hashed_token}

      {:error, _} ->
        {:error, "Invalid token"}
    end
  end
end

defmodule JobsApp.Services.UserTokenService do
  alias JobsApp.Schema.UserToken
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
end

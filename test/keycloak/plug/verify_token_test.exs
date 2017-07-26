defmodule Keycloak.Plug.VerifyTokenTest do
  use ExUnit.Case
  use Plug.Test

  alias Keycloak.Plug.VerifyToken

  setup do
    Application.put_env(:keycloak, Keycloak.Plug.VerifyToken,
                        hmac: "akbar", authorized_party: "test")
  end

  def fixture(:token) do
    Joken.token()
    |> Joken.with_claim("azp", "test")
    |> Joken.with_claim("sub", "Luke Skywalker")
    |> Joken.sign(VerifyToken.signer_key())
    |> Joken.get_compact()
  end

  test "fetch_token/1" do
    import VerifyToken, only: [fetch_token: 1]

    assert fetch_token([]) == nil
    assert fetch_token(["abc123"]) == nil
    assert fetch_token(["Bearer token"]) == "token"
    assert fetch_token(["bearer token"]) == "token"
    assert fetch_token(["invalid", "Bearer token"]) == "token"
  end

  test "verify_token/1 with invalid token" do
    import VerifyToken, only: [verify_token: 1]

    assert {:error, :not_authenticated} = verify_token(nil)
    assert {:error, "Invalid signature"} = verify_token("abc123")
    assert {:ok, %Joken.Token{}} = verify_token(fixture(:token))
  end
end

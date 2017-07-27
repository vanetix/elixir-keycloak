defmodule Keycloak.Plug.VerifyTokenTest do
  use ExUnit.Case
  use Plug.Test

  import Keycloak.Plug.VerifyToken

  doctest Keycloak.Plug.VerifyToken

  setup do
    Application.put_env(:keycloak, Keycloak.Plug.VerifyToken,
                        hmac: "akbar", authorized_party: "test")
  end

  def fixture(:token) do
    Joken.token()
    |> Joken.with_claim("azp", signer_azp())
    |> Joken.with_claim("sub", "Luke Skywalker")
    |> Joken.sign(signer_key())
    |> Joken.get_compact()
  end

  test "fetch_token/1" do
    assert fetch_token([]) == nil
    assert fetch_token(["abc123"]) == nil
    assert fetch_token(["Bearer token"]) == "token"
    assert fetch_token(["bearer token"]) == "token"
    assert fetch_token(["invalid", "Bearer token"]) == "token"
  end

  test "verify_token/1 with invalid token" do
    assert {:error, :not_authenticated} = verify_token(nil)
    assert {:error, "Invalid signature"} = verify_token("abc123")
    assert {:ok, %Joken.Token{}} = verify_token(fixture(:token))
  end

  test "call/2 with valid token" do
    conn =
      conn(:get, "/")
      |> put_req_header("authorization", "Bearer #{fixture(:token)}")
      |> call(%{})

    refute conn.halted
    assert %Plug.Conn{assigns: %{token: %Joken.Token{}}} = conn
  end

  test "call/2 with invalid token" do
    conn =
      conn(:get, "/")
      |> put_req_header("authorization", "bearer abc123")
      |> call(%{})

    assert conn.halted
    assert conn.status == 401
  end
end

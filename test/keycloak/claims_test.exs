defmodule Keycloak.ClaimsTest do
  use ExUnit.Case
  use Plug.Test

  import Keycloak.Claims

  def fixture(:token) do
    %Joken.Token{claims: %{"test" => "abc123"}}
  end

  def fixture(:conn) do
    conn(:get, "/")
    |> assign(:token, fixture(:token))
  end

  test "get_claim/2 with %Plug.Conn{}" do
    assert get_claim(fixture(:conn), "test") == "abc123"
    assert get_claim(fixture(:conn), "invalid") == nil
  end

  test "get_claim/2 with %Token{}" do
    assert get_claim(fixture(:token), "test") == "abc123"
    assert get_claim(fixture(:token), "invalid") == nil
  end
end

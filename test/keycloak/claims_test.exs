defmodule Keycloak.ClaimsTest do
  use ExUnit.Case
  use Plug.Test

  doctest Keycloak.Claims

  import Keycloak.Claims

  def fixture(:claims) do
    %{"test" => "abc123"}
  end

  def fixture(:conn) do
    conn(:get, "/")
    |> assign(:claims, fixture(:claims))
  end

  test "get_claim/2 with %Plug.Conn{}" do
    assert get_claim(fixture(:conn), "test") == "abc123"
    assert get_claim(fixture(:conn), "invalid") == nil
  end

  test "get_claim/2 with %Token{}" do
    assert get_claim(fixture(:claims), "test") == "abc123"
    assert get_claim(fixture(:claims), "invalid") == nil
  end
end

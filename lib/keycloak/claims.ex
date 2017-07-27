defmodule Keycloak.Claims do
  @moduledoc """
  A helper module for extracting claims from the `%Joken.Token{}`. In order
  to use these helpers, you **must** have the `VerifyToken` plug in your plug
  pipeline.

  ## Example

  ### Phoenix controller

      def index(conn, _) do
        sub = Keycloak.Claims.get_claim(conn, "sub")

        conn
        |> put_session(:user, sub)
        |> render("index.html")
      end
  """

  alias Plug.Conn
  alias Joken.Token

  @doc """
  Pulls given `claim` from the Joken token
  """
  @spec get_claim(Plug.Conn.t | Joken.Token.t, String.t) :: String.t | nil
  def get_claim(%Conn{assigns: %{token: token}}, claim),
    do: get_claim(token, claim)

  def get_claim(%Token{claims: claims}, claim) do
    case claims do
      %{^claim => value} -> value
      _ -> nil
    end
  end
end

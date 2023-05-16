defmodule Keycloak do
  @moduledoc """
  An OAuth2.Strategy implementation for authorizing with a
  [Keycloak](http://www.keycloak.org/) server.

  ## Example

  #### Phoenix controller

      def login(conn, _) do
        redirect(conn, external: Keycloak.authorize_url!())
      end

      def callback(conn, %{"code" => code}) do
        %{token: token} = Keycloak.get_token!(code: code)

        conn
        |> put_session(:token, token)
        |> redirect(to: "/manage")
      end
  """

  use OAuth2.Strategy

  alias Keycloak.Client
  alias OAuth2.Strategy.AuthCode

  def authorize_url!(params \\ []) do
    Client.new()
    |> OAuth2.Client.authorize_url!(params)
  end

  @doc """
  Creates a `OAuth2.Client` using the keycloak configuration and
  attempts fetch a access token.

  ## Example
  Get token based on client credentials:

    get_token!(grant_type: "client_credentials", code: "")

  """
  @spec get_token!(keyword(), keyword()) :: any()
  def get_token!(params \\ [], _headers \\ []) do
    data = Keyword.merge(params, client_secret: Client.new().client_secret)

    Client.new()
    |> OAuth2.Client.get_token!(data)
  end

  @doc """
  Returns the authorize url for the keycloak client.
  """
  @spec authorize_url(OAuth2.Client.t(), keyword()) :: any()
  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  @doc """
  Gets a token given a preconfigured `OAuth2.Client`.
  """
  @spec get_token(OAuth2.Client.t(), keyword(), keyword()) :: any()
  def get_token(client, params, headers) do
    client
    |> OAuth2.Client.put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end

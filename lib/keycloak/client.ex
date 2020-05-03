defmodule Keycloak.Client do
  @moduledoc """
  Module resposible for creating a properly configured
  `OAuth2.Client` for use with the Keycloak configuration.

  ## Configuration

      config :keycloak,
             realm: <REALM>
             site: <KEYCLOAK SERVER URL>
             client_id: <CLIENT_ID>
             client_secret: <CLIENT SECRET>
  """

  alias OAuth2.Client

  @spec config() :: keyword()
  defp config() do
    config = Application.get_all_env(:keycloak)
    {realm, config} = Keyword.pop(config, :realm)
    {site, config} = Keyword.pop(config, :site)

    [strategy: Keycloak,
     realm: realm,
     site: "#{site}/auth",
     authorize_url: "/realms/#{realm}/protocol/openid-connect/auth",
     token_url: "/realms/#{realm}/protocol/openid-connect/token",
     serializers: %{"application/json" => Poison}
    ]
    |> Keyword.merge(config)
  end

  @doc """
  Returns a new `OAuth2.Client` ready to make requests to the configured
  Keycloak server.
  """
  @spec new(keyword()) :: OAuth2.Client.t
  def new(opts \\ [])  do
    config()
    |> Keyword.merge(opts)
    |> Client.new
  end

  @doc """
  Fetches the current user profile from the Keycloak userinfo endpoint. The
  passed `client` must have already been authorized and have a valid access token.
  """
  @spec me(OAuth2.Client.t) :: {:ok, OAuth2.Response.t} | {:error, String.t}
  def me(%Client{} = client) do
    realm =
      config()
      |> Keyword.get(:realm)

    client
    |> Client.put_header("accept", "application/json")
    |> Client.get("/realms/#{realm}/protocol/openid-connect/userinfo")
  end
end

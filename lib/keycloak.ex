defmodule Keycloak do
  use OAuth2.Strategy

  alias Keycloak.Client
  alias OAuth2.Strategy.AuthCode

  def authorize_url!(params \\ []) do
    Client.new()
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], headers \\ []) do
    data = Keyword.merge(params, client_secret: Client.new().client_secret)

    Client.new()
    |> OAuth2.Client.get_token!(data)
  end

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> OAuth2.Client.put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end

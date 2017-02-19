defmodule Keycloak.Service do
  alias OAuth2.Client

  def get_token!(params \\ []) do
    case get_token() do
      {:ok, client} -> client
      {:error, error} -> raise error
    end
  end

  def get_token(params \\ []) do
    Keycloak.Client.new(strategy: OAuth2.Strategy.ClientCredentials)
    |> OAuth2.Client.get_token(params)
  end
end

defmodule Keycloak.Service do
  @moduledoc """
  Module that handles authorization flow for a client credentials grant


  ## Example

      client = Keycloak.Service.get_token!()

      users =
        case Keycloak.Admin.get(client, "/realms/test-realm/users") do
          {:ok, %{body: body}} -> body
          {:error, _} -> []
        end
  """

  alias OAuth2.Client

  @doc """
  Get a token for the configured OAuth2 client

  ### Example

    iex> Keycloak.Service.get_token!()
    %OAuth2.Client{
      token: %OAuth2.AccessToken{},
      expires_at: nil,
      other_params: %{},
      refresh_token: nil,
      token_type: "Bearer"
    }
  """
  @spec get_token(keyword()) :: {:ok, Client.t()} | {:error, Client.t()}
  def get_token(params \\ []) do
    Keyword.merge(params, strategy: OAuth2.Strategy.ClientCredentials)
    |> Keycloak.Client.new()
    |> OAuth2.Client.get_token(params)
  end

  @doc """
  Same as `get_token/1` but raises on error
  """
  @spec get_token!(keyword()) :: Client.t()
  def get_token!(params \\ []) do
    Keyword.merge(params, strategy: OAuth2.Strategy.ClientCredentials)
    |> Keycloak.Client.new()
    |> OAuth2.Client.get_token!(params)
  end
end

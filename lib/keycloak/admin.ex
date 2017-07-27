defmodule Keycloak.Admin do
  @moduledoc ~S"""
  This module is responsible for making calls to the Keycloak admin api.

  ## Example

      client = Keycloak.Client.new(token: "supersecret")

      case Keycloak.Admin.get(client, "/") do
        {:ok, %O{body: body}} ->
          body
        {:error, %{body: body}} ->
          "#{inspect body}"
      end

      response = OAuth2.Client.get!(client, "/some/resource")
  """

  alias OAuth2.Client

  @spec admin_client(Client.t) :: Client.t
  defp admin_client(%Client{site: base} = client) do
    %{client | site: "#{base}/admin"}
    |> Client.put_header("accept", "application/json")
  end

  @doc """
  Makes an authorized GET request to `url`
  """
  @spec get(Client.t, String.t) :: {atom(), OAuth2.Response.t}
  def get(%Client{} = client, url) do
    admin_client(client)
    |> Client.get(url)
  end

  @doc """
  Makes an authorized POST request to `url`
  """
  @spec post(Client.t, String.t) :: {atom(), OAuth2.Response.t}
  def post(%Client{} = client, url) do
    admin_client(client)
    |> Client.post(url)
  end
end

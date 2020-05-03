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

  @type result() :: {:ok, OAuth2.Response.t} | {:error, OAuth2.Response.t}
  @type headers() :: OAuth2.Client.headers()
  @type body() :: OAuth2.Client.body()

  @spec admin_client(Client.t) :: Client.t
  defp admin_client(%Client{site: base} = client) do
    %{client | site: "#{base}/admin"}
    |> Client.put_header("accept", "application/json")
  end

  @doc """
  Makes an authorized GET request to `url`
  """
  @spec get(Client.t, String.t, Keyword.t, headers(), Keyword.t) :: result()
  def get(%Client{} = client, url, params \\ [], headers \\ [], opts \\ []) do
    opts = Keyword.update(opts, :params, params, &Keyword.merge/2)
    client
    |> admin_client()
    |> Client.get(url, headers, opts)
  end

  @doc """
  Makes an authorized POST request to `url`
  """
  @spec post(Client.t, String.t, body(), Keyword.t, headers(), Keyword.t) :: result()
  def post(%Client{} = client, url, body \\ "", params \\ [], headers \\  [{"content-type", "application/json"}], opts \\ []) do
    opts = Keyword.update(opts, :params, params, &Keyword.merge/2)
    client
    |> admin_client()
    |> Client.post(url, body, headers, opts)
  end

  @doc """
  Makes an authorized PUT request to `url`
  """
  @spec put(Client.t, String.t, body(), Keyword.t, headers(), Keyword.t) :: result()
  def put(%Client{} = client, url, body \\ "", params \\ [], headers \\  [{"content-type", "application/json"}], opts \\ []) do
    opts = Keyword.update(opts, :params, params, &Keyword.merge/2)
    client
    |> admin_client()
    |> Client.put(url, body, headers, opts)
  end

  @doc """
  Makes an authorized DELETE request to `url`
  """
  @spec delete(Client.t, String.t, body(), Keyword.t, headers(), Keyword.t) :: result()
  def delete(%Client{} = client, url, body \\ "", params \\ [], headers \\  [{"content-type", "application/json"}], opts \\ []) do
    opts = Keyword.update(opts, :params, params, &Keyword.merge/2)
    client
    |> admin_client()
    |> Client.put(url, body, headers, opts)
  end

  @doc """
  A simple wrapper around the current `admin_client` functionality.

  NOTE: This is a temporary fix for some missing functionality.
  """
  def new(client), do: admin_client(client)
end

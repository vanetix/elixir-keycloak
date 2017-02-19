defmodule Keycloak.Client do
  alias OAuth2.Client

  defp config() do
    config = Application.get_all_env(:keycloak)
    {realm, config} = Keyword.pop(config, :realm)
    {site, config} = Keyword.pop(config, :site)

    [strategy: Keycloak,
     site: "#{site}/auth",
     authorize_url: "/realms/#{realm}/protocol/openid-connect/auth",
     token_url: "/realms/#{realm}/protocol/openid-connect/token"]
    |> Keyword.merge(config)
  end

  def new(opts \\ [])  do
    config()
    |> Keyword.merge(opts)
    |> Client.new
  end

  def me(%Client{} = client) do
    {realm, _} = Application.get_all_env(:keycloak)
                 |> Keyword.pop(:realm)

    client
    |> Client.put_header("accept", "application/json")
    |> Client.get("/realms/#{realm}/protocol/openid-connect/userinfo")
  end
end

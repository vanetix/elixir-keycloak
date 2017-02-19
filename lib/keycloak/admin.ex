defmodule Keycloak.Admin do
  alias OAuth2.Client

  defp admin_client(%Client{site: base} = client) do
    %{client | site: "#{base}/admin"}
    |> Client.put_header("accept", "application/json")
  end

  def get(%Client{} = client, url) do
    admin_client(client)
    |> Client.get(url)
  end

  def post(%Client{} = client, url) do
    admin_client(client)
    |> Client.post(url)
  end
end

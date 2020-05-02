defmodule Keycloak.Plug.VerifyToken do
  @moduledoc """
  Plug for verifying authorization on a per request basis, verifies that a token is set in the
  `Authorization` header.

  ### Example Usage

      config :keycloak, Keycloak.Plug.VerifyToken, hmac: "foo"

      # In your plug pipeline
      plug Keycloak.Plug.VerifyToken
  """
  use Joken.Config

  import Plug.Conn

  alias JOSE.JWK

  @regex ~r/^Bearer:?\s+(.+)/i

  @doc false
  def init(opts), do: opts

  @doc """
  Fetches the `Authorization` header, and verifies the token if present. If a
  valid token is passed, the decoded `%Joken.Token{}` is added as `:token`
  to the `conn` assigns.
  """
  @spec call(Plug.Conn.t, keyword()) :: Plug.Conn.t
  def call(conn, _) do
    token =
      conn
      |> get_req_header("authorization")
      |> fetch_token()

    case verify_token(token) do
      {:ok, claims} ->
        conn
        |> assign(:claims, claims)
      {:error, message} ->
        conn
        |> put_resp_content_type("application/vnd.api+json")
        |> send_resp(401, Poison.encode!(%{error: message}))
        |> halt()
    end
  end

  def token_config(), do: default_claims(default_exp: 60 * 60) # 1 hour
  @doc """
  Attemps to verify that the passed `token` can be trusted.

  ## Example

      iex> verify_token(nil)
      {:error, :not_authenticated}

      iex> verify_token("abc123")
      {:error, :signature_error}
  """
  @spec verify_token(String.t | nil) :: {atom(), Joken.Token.t | atom()}
  def verify_token(nil), do: {:error, :not_authenticated}
  def verify_token(token) do
    verify_and_validate(token, signer_key())
  end

  @doc """
  Fetches the token from the `Authorization` headers array, attempting
  to match the token in the format `Bearer <token>`.

  ### Example

      iex> fetch_token([])
      nil

      iex> fetch_token(["abc123"])
      nil

      iex> fetch_token(["Bearer abc123"])
      "abc123"
  """
  @spec fetch_token([String.t] | []) :: String.t | nil
  def fetch_token([]), do: nil
  def fetch_token([token | tail]) do
    case Regex.run(@regex, token) do
      [_, token] -> String.trim(token)
      nil -> fetch_token(tail)
    end
  end

  @doc """
  Returns the configured `public_key` or `hmac` key used to sign the token.

  ### Example

      iex> %Joken.Signer{} = signer_key()
      %Joken.Signer{
              alg: "HS512",
              jwk: %JOSE.JWK{fields: %{}, keys: :undefined, kty: {:jose_jwk_kty_oct, "akbar"}},
              jws: %JOSE.JWS{alg: {:jose_jws_alg_hmac, :HS512}, b64: :undefined, fields: %{"typ" => "JWT"}}
            }
  """
  @spec signer_key() :: Joken.Signer.t
  def signer_key() do
    {config, _} =
      :keycloak
      |> Application.get_env(__MODULE__, [])
      |> Keyword.split([:hmac, :public_key])

    case config do
      [hmac: hmac] ->
        hmac
        |> (&Joken.Signer.create("HS512", &1)).()
      [public_key: public_key] ->
        public_key
        |> JWK.from_pem()
        |> (&Joken.Signer.create("RS256", &1)).()
      _ ->
        raise "No signer configuration present for #{__MODULE__}"
    end
  end
end

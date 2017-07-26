defmodule Keycloak.Plug.VerifyToken do
  @moduledoc """
  Plug for verifying authorization on a per request basis, verifies that a token is set in the
  `Authorization` header.

  ## Configuration

      config :keycloak, Keycloak.Plug.VerifyToken,
        hmac: "foo"

  ## Examples

      plug Keycloak.Plug.VerifyToken
  """

  import Plug.Conn

  alias JOSE.JWK

  @regex ~r/^Bearer:?\s+(.+)/i

  @doc false
  def init(opts), do: opts

  @doc """
  Fetches the `Authorization` header, and verifies the token if present. If a
  valid token is passed, the decoded `%Joken.Token{}` is assigned as `:token`
  in the `conn` assigns.
  """
  @spec call(Plug.Conn.t, keyword()) :: Plug.Conn.t
  def call(conn, _) do
    token =
      conn
      |> get_req_header("authorization")
      |> fetch_token()

    case verify_token(token) do
      {:ok, token} ->
        conn
        |> assign(:token, token)
      {:error, message} ->
        conn
        |> put_resp_content_type("application/vnd.api+json")
        |> send_resp(401, Poison.encode!(%{error: message}))
        |> halt()
    end
  end

  @doc """
  Attemps to verify that the passed `token` can be trusted

  ## Examples

      iex> verify_token(nil)
      {:error, :not_authenticated}

      iex> verify_token("abc123")
      {:error, "Invalid signature"}
  """
  @spec verify_token(String.t | nil) :: {atom(), Joken.Token.t | atom()}
  def verify_token(nil), do: {:error, :not_authenticated}
  def verify_token(token) do
    joken =
      token
      |> Joken.token()
      |> Joken.with_validation("azp", &(&1 == signer_azp()), "Invalid azp")
      |> Joken.with_validation("exp", fn(exp) ->
        case DateTime.from_unix(exp) do
          {:ok, dt} -> DateTime.compare(dt, DateTime.utc_now()) == :gt
          {:error, _} -> false
        end
      end, "Invalid exp")
      |> Joken.with_signer(signer_key())
      |> Joken.verify()

    case joken do
      %{error: nil} -> {:ok, joken}
      %{error: message} -> {:error, message}
    end
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
  Returns the configured public_key or hmac key used to sign the token

  ## Example

      iex> Keycloak.Plug.VerifyToken.signer_key()
      %Joken.Signer{jwk: _, jws: _}
  """
  @spec signer_key() :: Joken.Signer.t
  def signer_key() do
    {config, _} =
      Application.get_env(:keycloak, __MODULE__, [])
      |> Keyword.split([:hmac, :public_key])

    case config do
      [hmac: hmac] ->
        hmac
        |> Joken.hs512()
      [public_key: public_key] ->
        public_key
        |> JWK.from_pem()
        |> Joken.rs256()
      _ ->
        raise "No signer configuration present for #{__MODULE__}"
    end
  end

  @doc """
  Returns the configured signer authorized party to validate
  """
  @spec signer_azp() :: String.t
  def signer_azp() do
    Application.get_env(:keycloak, __MODULE__, [])
    |> Keyword.get(:authorized_party, "keycloak")
  end
end

# Keycloak

[![Build Status](https://travis-ci.org/vanetix/elixir-keycloak.svg?branch=master)](https://travis-ci.org/vanetix/elixir-keycloak)

Elixir client for working with a Keycloak authorization server. API documentation can be found at https://hexdocs.pm/keycloak/0.1.1/.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `keycloak` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:keycloak, "~> 0.1.0"}]
end
```

## Configuration

### Base

```elixir
config :keycloak,
  realm: <REALM>
  site: <KEYCLOAK SERVER URL>
  client_id: <CLIENT_ID>
  client_secret: <CLIENT SECRET>
```

### Plugs

### VerifyToken

```elixir
config :keycloak, Keycloak.Plug.VerifyToken,
  hmac: "<hmac value>",
  public_key: "<public key>"
```

## Usage in Phoenix

```elixir
def login(conn, _) do
  redirect(conn, external: Keycloak.authorize_url!())
end

def callback(conn, %{"code" => code}) do
  %{token: token} = Keycloak.get_token!(code: code)

  conn
  |> put_session(:token, token)
  |> redirect(to: "/manage")
end
```

## License (MIT)

Copyright (c) 2017 Matt McFarland

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

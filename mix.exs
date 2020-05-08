defmodule Keycloak.Mixfile do
  use Mix.Project

  def project do
    [
      app: :keycloak,
      version: "0.2.2",
      elixir: "~> 1.6",
      name: "keycloak",
      description: "Library for interacting with a Keycloak authorization server",
      package: package(),
      deps: deps(),
      docs: [extras: ["README.md"], main: "readme"],
      source_url: "https://github.com/vanetix/elixir-keycloak"
    ]
  end

  # Configuration for the OTP application
  def application do
    [extra_applications: [:logger, :oauth2]]
  end

  defp deps do
    [
      {:joken, "~> 2.0"},
      {:oauth2, "~> 2.0"},
      {:plug, "~> 1.4"},
      {:poison, "~> 4.0"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false},
      {:rexbug, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Matthew McFarland"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/vanetix/elixir-keycloak"}
    ]
  end
end

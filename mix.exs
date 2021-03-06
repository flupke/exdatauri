defmodule ExDataURI.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exdatauri,
      version: "0.2.0",
      description: "A RFC 2397 URI parser for Elixir",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      test_coverage: [tool: ExCoveralls],
      package: package,
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:iconverl, github: "edescourtis/iconverl", tag: "3.0.17"},

      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.8", only: :dev},
      {:dialyze, "~> 0.2.0", only: :dev},

      {:excoveralls, "~> 0.3", only: :test},
    ]
  end

  defp package do
    [
      contributors: ["Luper Rouch"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/flupke/exdatauri"},
    ]
  end
end

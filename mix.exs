defmodule KurpoBot.MixProject do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))

  def project do
    [
      app: :kurpo_bot,
      deps: deps(),
      dialyzer: dialyzer(),
      elixir: "~> 1.10",
      elixirc_options: [warnings_as_errors: true],
      elixirc_paths: elixirc_paths(Mix.env()),
      releases: releases(),
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {KurpoBot.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:ecto_sql, "~> 3.0"},
      {:nostrum, github: "Kraigie/nostrum", branch: "master"},
      {:opentelemetry, "~> 1.0"},
      {:opentelemetry_api, "~> 1.0"},
      {:opentelemetry_exporter, "~> 1.0"},
      {:opentelemetry_ecto, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:ssl_verify_fun, "~> 1.1"}
    ]
  end

  defp releases do
    [
      kurpo_bot: [
        applications: [
          opentelemetry_exporter: :permanent,
          opentelemetry: :temporary,
          runtime_tools: :permanent
        ],
        include_executables_for: [:unix],
        path: "dist"
      ]
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end
end

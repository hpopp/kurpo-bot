defmodule KurpoBot.MixProject do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))

  def project do
    [
      app: :kurpo_bot,
      deps: deps(),
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
      {:ecto_sql, "~> 3.0"},
      {:nostrum, "~> 0.4"},
      {:postgrex, ">= 0.0.0"}
    ]
  end

  defp releases do
    [
      codedge: [
        applications: [
          runtime_tools: :permanent
        ],
        include_executables_for: [:unix],
        path: "dist"
      ]
    ]
  end
end

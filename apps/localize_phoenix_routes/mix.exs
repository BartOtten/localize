defmodule Localize.PhoenixRoutes.MixProject do
  use Mix.Project

  @source_url "https://github.com/BartOtten/localize"
  @version "0.1.0-alpha.1"
  @name "localize_phoenix_routes"

  def project do
    [
      app: :localize_phoenix_routes,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: @name,
      description: description(),
      source_url: @source_url,
      docs: docs(),
      package: package(),
      consolidate_protocols: Mix.env() != :test
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:localize, "~> 0.0.1"},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:localize, ">= 0.0.0"},
      {:routex, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: [:dev]}
    ]
  end

  defp package do
    [
      name: @name,
      maintainers: ["Bart Otten"],
      licenses: ["AGPL-3.0-only"],
      files: ~w(lib mix.exs),
      links: %{
        GitHub: @source_url
      }
    ]
  end

  defp description() do
    "Localize Phoenix Routes at Compile Time"
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end

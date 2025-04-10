defmodule LocalizeUmbrella.MixProject do
  use Mix.Project

  def project do
    [
      name: "localize_umrella",
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [{:ex_doc, ">= 0.0.0", only: [:dev]}]
  end
end



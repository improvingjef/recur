defmodule Recur.Mixfile do
  use Mix.Project

  def project do
    [
      app: :recur,
      version: "0.2.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      source_url: "https://github.com/improvingjef/recur"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps, do: []

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      maintainers: ["Jef Newsom"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/improvingjef/recur"}
    ]
  end
end

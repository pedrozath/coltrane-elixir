defmodule Coltrane.MixProject do
  use Mix.Project

  def project do
    [
      app: :coltrane,
      version: "0.0.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: Mix.compilers,
      description: description(),
      package: package()
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
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:distillery, "~> 2.0"}
    ]
  end

  defp description() do
    "A library to handle musical theory and representations"
  end

  defp package do
    [
      files: ~w(lib mix.exs README*),
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/pedrozath/coltrane-elixir"}
    ]
  end
end

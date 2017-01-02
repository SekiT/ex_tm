defmodule TuringMachine.Mixfile do
  use Mix.Project

  @github_url "https://github.com/SekiT/ex_tm"

  def project do
    [
      app: :ex_tm,
      version: "1.0.0",
      elixir: "~> 1.3",
      name: "ex_tm",
      description: description(),
      package: package(),
      source_url: @github_url,
      deps: deps(),
      docs: [
        main:   "TuringMachine",
        extras: ["README.md"],
      ],
      dialyzer: [plt_add_deps: :transitive],
      test_coverage: [tool: ExCoveralls],
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:ex_doc     , "~> 0.14.5", only: :dev },
      {:dialyxir   , "~> 0.4.1" , only: :dev },
      {:credo      , "~> 0.5.3" , only: :dev },
      {:excoveralls, "~> 0.5.7" , only: :test},
    ]
  end

  defp description do
    """
    Turing machine simulator in Elixir.
    """
  end

  defp package do
    [
      name: :ex_tm,
      licenses: ["WTFPL"],
      maintainers: ["Takaaki Seki"],
      links: %{"GitHub" => @github_url},
    ]
  end
end

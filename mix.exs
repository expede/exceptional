defmodule Exceptional.Mixfile do
  use Mix.Project

  def application, do: [applications: [:logger]]
  def project do
    [
      app:     :exceptional,
      name:    "Exceptional",

      description: "Common combinators for Elixir",
      package: [
        maintainers: ["Brooklyn Zelenka"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/expede/exceptional"}
      ],

      version: "0.1.0",
      elixir:  "~> 1.3",

      source_url:   "https://github.com/expede/exceptional",
      homepage_url: "https://github.com/expede/exceptional",

      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      deps: [
        {:earmark, "~> 1.0",  only: :dev},
        {:ex_doc,  "~> 0.13", only: :dev},
        {:inch_ex, "~> 0.5",  only: :docs}
      ],

      docs: [
        logo: "./logo.png",
        extras: ["README.md"]
      ]
    ]
  end
end

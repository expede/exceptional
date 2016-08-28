defmodule Exceptional.Mixfile do
  use Mix.Project

  def application, do: [applications: [:logger]]
  def project do
    [
      app:     :exceptional,
      name:    "Exceptional",
      description: "Helpers for Elixir exceptions",

      version: "1.0.4",
      elixir:  "~> 1.3",

      source_url:   "https://github.com/expede/exceptional",
      homepage_url: "https://github.com/expede/exceptional",

      package: [
        maintainers: ["Brooklyn Zelenka"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/expede/exceptional"}
      ],

      aliases: ["quality": ["test", "credo --strict"]],

      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      deps: [
        {:credo,   "~> 0.4",  only: [:dev, :test]},
        {:earmark, "~> 1.0",  only: :dev},
        {:ex_doc,  "~> 0.13", only: :dev},
        {:inch_ex, "~> 0.5",  only: :docs}
      ],

      docs: [
        logo: "./branding/logo.png",
        extras: ["README.md"]
      ]
    ]
  end
end

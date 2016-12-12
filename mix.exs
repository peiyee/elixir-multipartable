defmodule Multipartable.Mixfile do
  use Mix.Project

  def project do
    [app: :multipartable,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Build a simple or nested multipart form body",
     package: package(),
     deps: deps(),
     source_url: "https://github.com/peiyee/elixir-multipartable"]
  end

  defp package do
    [
      maintainers: ["Teh Pei Yee"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/peiyee/elixir-multipartable"}
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end
end

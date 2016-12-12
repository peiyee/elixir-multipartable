# Multipartable

Build a multipart form body.

General Usage Example

```elixir
file_headers = %{
  "Content-Transfer-Encoding" => "binary",
  "Content-Disposition" => "form-data",
  "Content-Type"=>"text/html"
}

file_opts = %{name: "file_upload", filename: "text.txt"}

data_headers = %{"Content-Type" => "string"}
data_opts = %{name: "some_params"}
data_content = "some params value"

parts = [
  {:file, file_headers, file_content, file_opts},
  {:data, data_headers, data_content, data_opts}
]
boundary = "-------elixirMultipartBoundary"

# require a list of parts
# each part is a tuple where first element is atom(:file, :data, or :multipart),
# second element map headers, third element is the content and last element is
# map optional attributes
Multipartable.build(boundary, parts) == expected

```

To construct a nested multipart form body.

```elixir

nested_parts = [{:data, data_headers, data_content, data_opts}]
parts = [
  {:file, file_headers, file_content, file_opts},
  {:multipart, "-------elixirMultipartBoundaryNested", nested_parts}
]
boundary = "-------elixirMultipartBoundary"
Multipartable.build(boundary, parts) == expected


```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `multipartable` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:multipartable, "~> 0.1.0"}]
    end
    ```

  2. Ensure `multipartable` is started before your application:

    ```elixir
    def application do
      [applications: [:multipart_post]]
    end
    ```

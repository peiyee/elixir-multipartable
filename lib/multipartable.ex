defmodule Multipartable do
  def build(boundary, list) do
    parts = Enum.map(list, fn(p) ->
      case p do
        {:file, headers, content, opts} ->
           build_file_part(boundary, headers, content, opts)
        {:data, headers, content, opts} ->
          build_data_part(boundary, headers, content, opts)
        {:multipart, boundary, list} -> Multipartable.build(boundary, list)
      end
    end)
    parts ++ epilogue(boundary)
    |> Enum.join
  end

  def build_file_part(boundary, headers, content, opts \\ %{}) do
    transfer_encoding =
      case headers do
        %{"Content-Transfer-Encoding" => v} -> v
        _ -> "binary"
      end

    content_disposition =
      case headers do
        %{"Content-Disposition" => v} -> v
        _ -> "form-data"
      end

    content_len = byte_size(content)
    "--#{boundary}\r\n" <>
    "Content-Disposition: #{content_disposition}; #{content_disposition_options(opts)}\r\n" <>
    "Content-Length: #{content_len}\r\n" <>
    "Content-Type: #{headers["Content-Type"]}\r\n" <>
    "Content-Transfer-Encoding: #{transfer_encoding}\r\n" <>
    "\r\n" <>
    "#{content}\r\n"
  end

  def build_data_part(boundary, headers, content, opts \\ %{}) do
    "--#{boundary}\r\n" <>
    "Content-Disposition: form-data; #{content_disposition_options(opts)}\r\n" <>
    "Content-Type: #{headers["Content-Type"]}\r\n" <>
    "\r\n" <>
    "#{content}\r\n"
  end

  def epilogue(boundary) do
    ["--#{boundary}--\r\n"]
  end

  defp content_disposition_options(opts) do
    Enum.map(opts, fn{k, v} -> "#{k}=\"#{v}\";" end) |> Enum.join
  end
end

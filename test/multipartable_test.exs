defmodule MultipartableTest do
  use ExUnit.Case
  doctest Multipartable

  @boundary "-------elixirMultipartBoundary"
  @secondary_boundary "-------elixirMultipartBoundarySecond"

  test "build params part" do
    content = "some content text"
    headers = %{"Content-Type" => "text"}
    opts = %{name: "all"}

    expected =
      "--#{@boundary}\r\n" <>
      "Content-Disposition: form-data; name=\"all\";\r\nContent-Type: text\r\n" <>
      "\r\n" <>
      "#{content}\r\n"

    assert Multipartable.build_data_part(@boundary, headers, content, opts) == expected
  end

  test "build file part" do
    content = "some text"
    headers = %{
      "Content-Transfer-Encoding" => "binary",
      "Content-Disposition" => "form-data",
      "Content-Type"=>"text/html"
    }
    opts = %{name: "file_upload", filename: "text.txt"}

    expected =
      "--#{@boundary}\r\n" <>
      "Content-Disposition: form-data; filename=\"text.txt\";name=\"file_upload\";\r\n" <>
      "Content-Length: 9\r\n" <>
      "Content-Type: text/html\r\n" <>
      "Content-Transfer-Encoding: binary\r\n\r\n" <>
      "#{content}\r\n"

    assert Multipartable.build_file_part(@boundary, headers, content, opts) == expected
  end

  test "build multipart" do
    file_content = "some text"
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

    expected =
      "---------elixirMultipartBoundary\r\n" <>
      "Content-Disposition: form-data; filename=\"text.txt\";name=\"file_upload\";\r\n" <>
      "Content-Length: 9\r\nContent-Type: text/html\r\nContent-Transfer-Encoding: binary\r\n" <>
      "\r\n" <>
      "#{file_content}\r\n" <>
      "---------elixirMultipartBoundary\r\n" <>
      "Content-Disposition: form-data; name=\"some_params\";\r\n" <>
      "Content-Type: string\r\n" <>
      "\r\n" <>
      "#{data_content}\r\n" <>
      "---------elixirMultipartBoundary--\r\n"

    assert Multipartable.build(@boundary, parts) == expected
  end

  test "build nested multipart" do
    file_content = "some text"
    file_headers = %{
      "Content-Transfer-Encoding" => "binary",
      "Content-Disposition" => "form-data",
      "Content-Type"=>"text/html",
      name: "file_upload",
      filename: "text.txt"
    }
    file_opts = %{name: "file_upload", filename: "text.txt"}

    data_headers = %{"Content-Type" => "string"}
    data_opts = %{name: "some_params"}
    data_content = "some params value"


    parts_1 = [
      {:data, data_headers, data_content, data_opts},
      {:data, data_headers, data_content, data_opts}
    ]

    parts_2 = [
      {:file, file_headers, file_content, file_opts},
      {:data, data_headers, data_content, data_opts},
      {:multipart, @secondary_boundary, parts_1}
    ]

    nested_multipart =
      "---------elixirMultipartBoundarySecond\r\n" <>
      "Content-Disposition: form-data; name=\"some_params\";\r\n" <>
      "Content-Type: string\r\n" <>
      "\r\n" <>
      "#{data_content}\r\n" <>
      "---------elixirMultipartBoundarySecond\r\n" <>
      "Content-Disposition: form-data; name=\"some_params\";\r\n" <>
      "Content-Type: string\r\n" <>
      "\r\n" <>
      "#{data_content}\r\n" <>
      "---------elixirMultipartBoundarySecond--\r\n"

    expected =
      "---------elixirMultipartBoundary\r\n" <>
      "Content-Disposition: form-data; filename=\"text.txt\";name=\"file_upload\";\r\n" <>
      "Content-Length: 9\r\nContent-Type: text/html\r\nContent-Transfer-Encoding: binary\r\n" <>
      "\r\n" <>
      "#{file_content}\r\n" <>
      "---------elixirMultipartBoundary\r\n" <>
      "Content-Disposition: form-data; name=\"some_params\";\r\n" <>
      "Content-Type: string\r\n" <>
      "\r\n" <>
      "#{data_content}\r\n" <>
      "#{nested_multipart}" <>
      "---------elixirMultipartBoundary--\r\n"

    assert Multipartable.build(@boundary, parts_2) == expected
  end
end

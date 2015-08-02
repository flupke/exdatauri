defmodule ExDataURI do
  @moduledoc """
  Encode and decode RFC 2397 URIs.

  `data:[<mediatype>][;base64],<data>`
  """

  @doc """
  Parse RFC 2397 `uri`.

  Return `{:ok, mime_type, data}`, or `{:error, reason}`.
  """
  def parse("data:" <> data) do
    parse_mediatype(data)
  end
  def parse(uri) do
    {:error, "malformed RFC 2397 URI, missing \"data:\" prefix"}
  end

  defp parse_mediatype(data) do
    if String.contains?(data, ";") do
      [mime, tail] = String.split(data, ";", parts: 2)
      parse_encoding(mime, tail)
    else
      {:error, "malformed RFC 2397 URI, could not find mime type"}
    end
  end

  defp parse_encoding(mime, data) do
    if String.contains?(data, ",") do
      [encoding, payload] = String.split(data, ",", parts: 2)
      decode_payload(mime, encoding, payload)
    else
      {:error, "malformed RFC 2397 URI, could not find encoding"}
    end
  end

  defp decode_payload(mime, "base64", payload) do
    case Base.decode64(payload) do
      {:ok, data} ->
        {:ok, mime, data}
      :error ->
        {:error, "malformed RFC 2397 URI, could not decode payload"}
    end
  end
  defp decode_payload(mime, encoding, payload) do
    {:error, "malformed RFC 2397 URI, invalid encoding: #{encoding}"}
  end
end

defmodule ExDataURI do
  @moduledoc """
  Encode and decode RFC 2397 URIs.

  `data:[<mediatype>][;base64],<data>`
  """

  @doc """
  Parse RFC 2397 `uri`.

  Return `{:ok, mediatype_type, data}`, or `{:error, reason}`.
  """
  def parse("data:" <> data) do
    if String.contains?(data, ",") do
      [metadata, payload] = String.split(data, ",", parts: 2)
      case parse_metadata(metadata) do
        {mediatype, charset, payload_encoding} ->
          case decode_payload(charset, payload_encoding, payload) do
            {:ok, payload} ->
              {:ok, mediatype, payload}
            {:error, reason} ->
              {:error, reason}
          end
        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, "malformed RFC 2397 URI, missing \",\""}
    end
  end
  def parse(_uri) do
    {:error, "malformed RFC 2397 URI, missing \"data:\" prefix"}
  end

  defp parse_metadata(metadata) do
    if String.ends_with?(metadata, ";base64") do
      metadata = String.slice(metadata, 0..-8)
      payload_encoding = :base64
    else
      payload_encoding = :urlenc
    end
    case parse_mediatype(metadata) do
      {:ok, mediatype, charset} ->
        if mediatype == "" do
          mediatype = "text/plain"
        end
        {mediatype, charset, payload_encoding}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_mediatype(mediatype) do
    if String.contains?(mediatype, ";") do
      [mediatype | parameters] = String.split(mediatype, ";")
      parameters = parameters
                   |> Enum.map(fn(param) ->
                       [name, value] = String.split(param, "=", parts: 2)
                       {name, value}
                     end)
                   |> Enum.into(%{})
      {charset, rest} = Map.pop(parameters, "charset")
      if rest == %{} do
        {:ok, mediatype, charset}
      else
        {:error, "unsupported mediatype parameters in RFC 2397 URI: #{inspect Map.keys(rest)}"}
      end
    else
      {:ok, mediatype, nil}
    end
  end

  defp decode_payload(charset, payload_encoding, payload) do
    case decode_payload(payload_encoding, payload) do
      {:ok, payload} ->
        if charset != nil do
          case :iconverl.conv("utf8", charset, payload) do
            {:ok, payload} ->
              {:ok, payload}
            {:error, reason} ->
              {:error, "malformed RFC 2397 URI, can't decode payload charset: #{inspect reason}"}
          end
        else
          {:ok, payload}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end
  defp decode_payload(:base64, payload) do
    case Base.decode64(payload) do
      {:ok, payload} ->
        {:ok, payload}
      :error ->
        {:error, "malformed RFC 2397 URI, could not decode base64 payload"}
    end
  end
  defp decode_payload(:urlenc, payload) do
    try do
      {:ok, URI.decode(payload)}
    rescue
      ArgumentError ->
        {:error, "malformed RFC 2397 URI, could not decode URI encoded payload"}
    end
  end
end

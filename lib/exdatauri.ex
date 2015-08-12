defmodule ExDataURI do
  @moduledoc """
  An Elixir parser and encoder for RFC 2397 URIs.

  Usage:
  ```
  iex> ExDataURI.parse("data:text/plain;base64,Zm9v")
  {:ok, "text/plain", "foo"}
  iex> ExDataURI.encode("foo")
  {:ok, "data:text/plain;base64,Zm9v"}
  ```
  """

  @doc """
  Create a RFC 2397 URI.

  `payload_encoding` may be `:base64` or `:urlenc`.

  `charset` may be any charset supported by iconv, or `nil`. If it's `nil`, the
  payload is stored as-is (the default); if it's not, use iconv to convert
  payload from `input_charset` to `charset`.

  Return values:
    * `{:ok, uri}`
    * `{:error, reason}`
  """
  @spec encode(bitstring, String.t, String.t | nil, :base64 | :urlenc, String.t) :: {:ok | :error, String.t}
  def encode(payload,
             mediatype \\ "text/plain",
             charset \\ nil,
             payload_encoding \\ :base64,
             input_charset \\ "utf8") do
    error = nil

    case charset do
      nil ->
        charset_meta = ""
      ^input_charset ->
        charset_meta = ";charset=#{charset}"
      charset ->
        case :iconverl.conv(charset, input_charset, payload) do
          {:ok, payload} ->
            payload = payload
            charset_meta = ";charset=#{charset}"
          {:error, reason} ->
            error = {:error, "failed encoding payload from #{inspect input_charset} to #{inspect charset}: #{inspect reason}"}
        end
    end

    unless error do
      case payload_encoding do
        :base64 ->
          payload_meta = ";base64"
          payload = Base.encode64(payload)
        :urlenc ->
          payload_meta = ""
          payload = URI.encode(payload)
        _unknonw_enc ->
          error = {:error, "unknown payload encoding: #{inspect payload_encoding}"}
      end
    end

    case error do
      nil ->
        {:ok, "data:#{mediatype}#{charset_meta}#{payload_meta},#{payload}"}
      error ->
        error
    end
  end

  @doc """
  Parse a RFC 2397 URI.

  Return values:
    * `{:ok, mediatype, data}` - where `mediatype` is the one given in the
      metadata, or `"text/plain"` if it's omitted;
    * `{:error, reason}`
  """
  @spec parse(String.t) :: {:ok | :error, String.t}
  def parse("data:" <> data) do
    if String.contains?(data, ",") do
      [metadata, payload] = String.split(data, ",", parts: 2)
      case parse_metadata(metadata) do
        {:ok, mediatype, charset, payload_encoding} ->
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

  @doc """
  Only parse metadata of an RFC 2397 URI.

  Return values:
    * `{:ok, mediatype, charset, payload_encoding}` - where `mediatype` is the
      MIME type (`"text/plain"` by default), `charset` the encoding of the
      payload or `nil`, and `payload_encoding` is one of `:urlenc` or `:base64`
    * `{:error, reason}`
  """
  @spec parse_metadata(String.t) :: {:ok, String.t, String.t | nil, :atom} | {:error, String.t}
  def parse_metadata("data:" <> rest) do
    [metadata, _payload] = String.split(rest, ",", parts: 2)
    parse_metadata(metadata)
  end
  def parse_metadata(metadata) do
    if String.ends_with?(metadata, ";base64") do
      metadata = String.slice(metadata, 0..-8)
      payload_encoding = :base64
    else
      payload_encoding = :urlenc
    end
    case parse_mediatype(metadata) do
      {:ok, mediatype, charset} ->
        {:ok, mediatype, charset, payload_encoding}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_mediatype("") do
    {:ok, "text/plain", nil}
  end
  defp parse_mediatype(mediatype) do
    if String.contains?(mediatype, ";") do
      [mediatype | parameters] = String.split(mediatype, ";")
      case parse_charset(parameters) do
        {:ok, charset} ->
          {:ok, mediatype, charset}
        {:error, reason} ->
          {:error, reason}
      end
    else
      if String.contains?(mediatype, "/") do
        {:ok, mediatype, nil}
      else
        parameters = String.split(mediatype, ";")
        case parse_charset(parameters) do
          {:ok, charset} ->
            {:ok, "text/plain", charset}
          {:error, reason} ->
            {:error, reason}
        end
      end
    end
  end

  defp parse_charset(parameters) do
    parameters = parameters
                 |> Enum.map(fn(param) ->
                     [name, value] = String.split(param, "=", parts: 2)
                     {name, value}
                   end)
                 |> Enum.into(%{})
    {charset, rest} = Map.pop(parameters, "charset")
    if rest == %{} do
      {:ok, charset}
    else
      {:error, "unsupported mediatype parameters in RFC 2397 URI: #{inspect Map.keys(rest)}"}
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

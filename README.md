ExDataURI
=========

An Elixir decoder and encoder for RFC 2397 URIs.

Usage:
```
iex> ExDataURI.decode("data:text/plain;base64,Zm9v")
{:ok, "text/plain", "foo"}
iex> ExDataURI.encode("text/plain", "foo")
"data:text/plain;base64,Zm9v"
```

ExDataURI
=========

An Elixir parser and encoder for RFC 2397 URIs.

Usage:
```
iex> ExDataURI.parse("data:text/plain;base64,Zm9v")
{:ok, "text/plain", "foo"}
iex> ExDataURI.encode("text/plain", "foo", :base64)
{:ok, "data:text/plain;base64,Zm9v"}
```

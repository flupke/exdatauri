ExDataURI
=========

[![Build Status](https://travis-ci.org/flupke/exdatauri.svg?branch=master)](https://travis-ci.org/flupke/exdatauri) [![Coverage Status](https://coveralls.io/repos/flupke/exdatauri/badge.svg?branch=master&service=github)](https://coveralls.io/github/flupke/exdatauri?branch=master)

An Elixir parser and encoder for RFC 2397 URIs.

Usage:
```
iex> ExDataURI.parse("data:text/plain;base64,Zm9v")
{:ok, "text/plain", "foo"}
iex> ExDataURI.encode("foo")
{:ok, "data:text/plain;base64,Zm9v"}
```

defmodule ExDataURITest do
  use ExUnit.Case

  test "base64" do
    assert ExDataURI.parse("data:image/gif;base64,#{Base.encode64 "foo"}") == {:ok, "image/gif", "foo"}
  end

  test "implicit mediatype and encoding" do
    assert ExDataURI.parse("data:,foo") == {:ok, "text/plain", "foo"}
  end

  test "implicit encoding" do
    assert ExDataURI.parse("data:image/gif,#{URI.encode("foé")}") == {:ok, "image/gif", "foé"}
  end

  test "implicit mediatype" do
    assert ExDataURI.parse("data:;base64,#{Base.encode64("foo")}") == {:ok, "text/plain", "foo"}
  end

  test "explicit charset" do
    assert ExDataURI.parse(<<"data:text/plain;charset=iso-8859-15,", 233>>) == {:ok, "text/plain", "é"}
  end

  test "explicit charset, no mediatype" do
    assert ExDataURI.parse(<<"data:charset=iso-8859-15,", 233>>) == {:ok, "text/plain", "é"}
  end
end

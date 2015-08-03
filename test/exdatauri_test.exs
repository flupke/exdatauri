defmodule ExDataURITest do
  use ExUnit.Case, async: true

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

  test "unsupported mediatype parameters" do
    assert {:error, _} = ExDataURI.parse("data:text/plain;foo=bar,foo")
  end

  test "invalid payload for charset" do
    assert {:error, _} = ExDataURI.parse("data:charset=utf8,%E9")
  end

  test "default encode parameters" do
    assert ExDataURI.encode("foo") == {:ok, "data:text/plain;base64,Zm9v"}
    assert ExDataURI.encode("é") == {:ok, "data:text/plain;base64,w6k="}
  end

  test "all encode parameters" do
    assert ExDataURI.encode("é", "image/gif", "latin1", :urlenc, "utf8") ==
      {:ok, "data:image/gif;charset=latin1,%E9"}
    assert ExDataURI.encode("é", "image/gif", "utf8", :urlenc, "utf8") ==
      {:ok, "data:image/gif;charset=utf8,%C3%A9"}
  end

  test "invalid encode charset conversion" do
    assert {:error, _} = ExDataURI.encode(<<233>>, "text/plain", "latin1", :urlenc, "utf8")
  end

  test "invalid payload encoding" do
    assert {:error, _} = ExDataURI.encode("foo", "text/plain", "utf8", :unknown)
  end
end

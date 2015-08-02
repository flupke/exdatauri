defmodule ExDataURITest do
  use ExUnit.Case

  test "base64" do
    assert ExDataURI.parse("data:text/plain;base64,#{Base.encode64 "foo"}") == {:ok, "text/plain", "foo"}
  end

  test "implicit mediatype and encoding" do
    assert ExDataURI.parse("data:,foo") == {:ok, "text/plain", "foo"}
  end
end

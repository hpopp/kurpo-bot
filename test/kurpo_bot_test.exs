defmodule KurpoBotTest do
  use ExUnit.Case
  doctest KurpoBot

  test "greets the world" do
    assert KurpoBot.hello() == :world
  end
end

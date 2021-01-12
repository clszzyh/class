defmodule ClassTest do
  use ExUnit.Case
  doctest Class

  test "greets the world" do
    assert Class.hello() == :world
  end
end

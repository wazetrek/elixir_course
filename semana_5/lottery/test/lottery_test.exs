defmodule LotteryTest do
  use ExUnit.Case
  doctest Lottery

  test "greets the world" do
    assert Lottery.hello() == :world
  end
end

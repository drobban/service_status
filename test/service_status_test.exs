defmodule ServiceStatusTest do
  use ExUnit.Case
  doctest ServiceStatus

  test "greets the world" do
    assert ServiceStatus.hello() == :world
  end
end

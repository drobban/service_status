defmodule ServiceStatusTest do
  use ExUnit.Case
  doctest ServiceStatus

  test "greets the world" do
    assert :test == :test
  end

  test "callback status" do
    assert ServiceStatus.status() == %{}
  end
end

defmodule ServiceStatus.Monitor.Util do

  def is_ok(url) do 
    status = Req.get!(url) |> Map.get(:status)

    case status do 
      200 -> 
        true
      _ ->
        false
    end
  end
end

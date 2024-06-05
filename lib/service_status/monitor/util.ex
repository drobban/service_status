defmodule ServiceStatus.Monitor.Util do
  require Logger

  def is_ok(url) do
    status = Req.get!(url) |> Map.get(:status)

    case status do
      200 ->
        true

      404 = not_found ->
        Logger.debug("Page not found #{not_found} from - #{url}")
        false

      unknown ->
        Logger.debug("Got: #{unknown} from - #{url}")
        false
    end
  end

  def response_time(url, unit \\ :millisecond) do
    req_date = DateTime.now!("Etc/UTC")
    Req.get!(url)
    response_date = DateTime.now!("Etc/UTC")
    td = DateTime.diff(response_date, req_date, unit)
    Logger.debug("Time delay in #{inspect(unit)}: #{td}")

    td
  end
end

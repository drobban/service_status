defmodule ServiceStatus.Monitor.Util do
  require Logger

  def is_ok(url) do
    {status, resp} =
      Req.get(url, max_retries: 0, pool_timeout: 1000, connect_options: [timeout: 500])

    response_status =
      if status == :ok do
        resp |> Map.get(:status)
      else
        0
      end

    case response_status do
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
    Req.get(url, max_retries: 0, pool_timeout: 1000, connect_options: [timeout: 500])
    response_date = DateTime.now!("Etc/UTC")

    td = DateTime.diff(response_date, req_date, unit)
    Logger.debug("Time delay in #{inspect(unit)}: #{td}")

    td
  end

  def response_stat(url, unit \\ :millisecond) do
    req_date = DateTime.now!("Etc/UTC")

    # :unprocessed - We are getting into situations where the server has closed a connection.
    # When that happens, we should give it a try again.
    {status, resp} =
      Req.get(url, max_retries: 2, pool_timeout: 1000, connect_options: [timeout: 500])

    response_date = DateTime.now!("Etc/UTC")

    response_status =
      if status == :ok do
        resp |> Map.get(:status)
      else
        Logger.warning("Request response: #{inspect(status)} - response: #{inspect(resp)}")
        0
      end

    td = DateTime.diff(response_date, req_date, unit)

    case response_status do
      200 ->
        {td, true, ""}

      404 = not_found ->
        Logger.warning("Page not found #{not_found} from - #{url}")
        {td, false, "Request response: #{inspect(status)} - response: #{inspect(resp)}"}

      unknown ->
        Logger.warning("Got: #{unknown} from - #{url}")
        {td, false, "Request response: #{inspect(status)} - response: #{inspect(resp)}"}
    end
  end
end

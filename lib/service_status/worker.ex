defmodule ServiceStatus.Worker do
  require Logger
  use GenServer
  alias ServiceStatus.Config
  alias ServiceStatus.Monitor.Util
  alias ServiceStatus.Message.Status

  def start_link(arg) do
    IO.inspect("#{inspect(arg)}")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(initial_state) do
    {:ok, initial_state, {:continue, initial_state}}
  end

  def handle_continue(setup_args, state) do
    Logger.debug("Setup with default args/or state pre-crash")
    Logger.debug("#{inspect(setup_args)}")

    {:noreply, state}
  end

  def handle_cast(:status, state) do
    Logger.debug("Show state: #{inspect(state)}")
    {:noreply, state}
  end

  def handle_cast({:register, %{name: name, config: %Config{} = config}}, state) do
    Logger.info("Registered #{name} - Config: #{config.url}")

    schedule_monitor(name, config)

    state =
      state |> Map.put(name, config)

    {:noreply, state}
  end

  def handle_info({:monitor, name}, state) do
    %Config{url: url, client: pid} = state[name]

    ping_status = Util.is_ok(url)
    response_time = Util.response_time(url, :millisecond)

    msg = %Status{
      alias: name,
      url: url,
      response_time: response_time,
      time_unit: :millisecond,
      ok: ping_status
    }

    if !is_nil(pid) do
      Process.send(pid, msg, [:noconnect, :nosuspend])
    end

    Logger.debug(inspect(msg))
    schedule_monitor(name, state[name])
    {:noreply, state}
  end

  defp schedule_monitor(name, %Config{} = config) do
    # We schedule the work to happen in config.interval seconds 
    # (written in milliseconds).
    Process.send_after(self(), {:monitor, name}, config.interval * 1000)
  end
end

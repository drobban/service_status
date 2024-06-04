defmodule ServiceStatus.Worker do
  use GenServer
  alias ServiceStatus.Config
  alias ServiceStatus.Monitor.Util

  def start_link(arg) do
    IO.inspect("#{inspect(arg)}")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(initial_state) do
    {:ok, initial_state, {:continue, initial_state}}
  end

  def handle_continue(setup_args, state) do
    IO.inspect("If we have a initial set of keys in state lets run em as if registered")
    IO.inspect("#{inspect(setup_args)}")

    {:noreply, state}
  end

  def handle_cast(:status, state) do
    IO.inspect("Show state: #{inspect(state)}")
    {:noreply, state}
  end

  def handle_cast({:register, %{name: name, config: %Config{} = config}}, state) do
    IO.inspect("#{name} - Config: #{config.url}")

    schedule_monitor(name, config)

    state =
      state |> Map.put(name, config)

    {:noreply, state}
  end

  def handle_info({:monitor, name}, state) do
    %Config{url: url} = state[name]
    
    IO.inspect("#{inspect DateTime.now!("Etc/UTC")} Ping: #{url} #{inspect Util.is_ok(url)}")

    schedule_monitor(name, state[name])
    {:noreply, state}
  end

  defp schedule_monitor(name, %Config{} = config) do
    # We schedule the work to happen in config.interval seconds 
    # (written in milliseconds).
    Process.send_after(self(), {:monitor, name}, config.interval * 1000)
  end
end
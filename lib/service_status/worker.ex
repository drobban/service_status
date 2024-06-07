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

  def handle_cast({:register, %{name: name, config: %Config{internal_id: id} = config}}, state) do
    Logger.info("Registered #{name} - Config: #{config.url}")

    configs = 
      state
      |> Map.get(name, %{})

    configs =
      configs
      |> Map.put(id, config)

    schedule_monitor(name, config)

    state =
      state |> Map.put(name, configs)

    {:noreply, state}
  end

  def handle_cast({:unregister, %{name: name, id: id}}, state) do
    Logger.info("Unregistered #{name}")

    state =
      state
      |> Map.update(name, %{}, 
        fn configs -> {_, cleared_configs} = Map.pop(configs, id)
          cleared_configs
        end)

    Logger.debug("Conf droppen: #{name} : #{id}")
    {:noreply, state}
  end

  def handle_info({:monitor, {name, id}}, state) do
    state_conf = 
      state
      |> get_in([name, id])

    if ! is_nil(state_conf) do
      %Config{url: url, client: pid, internal_id: id} = state_conf

      {response_time, ping_status} = Util.response_stat(url, :millisecond)

      msg = %Status{
        alias: name,
        url: url,
        response_time: response_time,
        time_unit: :millisecond,
        ok: ping_status,
        id: id
      }

      if !is_nil(pid) do
        Process.send(pid, msg, [:noconnect, :nosuspend])
      end

      Logger.debug(inspect(msg))
      schedule_monitor(name, state_conf)
    else
      Logger.debug("Service unregistered: #{name}")  
    end

    {:noreply, state}
  end

  defp schedule_monitor(name, %Config{} = config) do
    # We schedule the work to happen in config.interval seconds 
    # (written in milliseconds).
    Process.send_after(self(), {:monitor, {name, config.internal_id}}, config.interval * 1000)
  end
end

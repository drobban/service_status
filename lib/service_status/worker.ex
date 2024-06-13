defmodule ServiceStatus.Worker do
  require Logger
  use GenServer
  alias ServiceStatus.Message.Debug
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

  def handle_call(:status, _from, state) do
    {:reply, state, state}
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

    old_config =
      state
      |> Map.get(name, %{})
      |> Map.get(id, nil)

    if !is_nil(old_config) do
      # Abort old timer.
      Process.cancel_timer(old_config.monitor)
    end

    monitor_ref = schedule_monitor(name, config)
    config = %Config{config | monitor: monitor_ref}

    configs =
      configs
      |> Map.put(id, config)

    state =
      state |> Map.put(name, configs)

    {:noreply, state}
  end

  def handle_cast({:unregister, %{name: name, id: id}}, state) do
    Logger.info("Unregistered #{name}")

    state =
      state
      |> Map.update(name, %{}, fn configs ->
        {_, cleared_configs} = Map.pop(configs, id)
        cleared_configs
      end)

    Logger.debug("Conf droppen: #{name} : #{id}")
    {:noreply, state}
  end

  def handle_info({:monitor, {name, id}}, state) do
    state_conf =
      state
      |> get_in([name, id])

    monitor_ref =
      if !is_nil(state_conf) do
        %Config{url: url, client: pid, internal_id: id} = state_conf

        {response_time, ping_status, debug} = Util.response_stat(url, :millisecond)

        msg = %Status{
          alias: name,
          url: url,
          response_time: response_time,
          time_unit: :millisecond,
          ok: ping_status,
          id: id
        }

        debug_msg = %Debug{message: debug}

        if !is_nil(pid) do
          Process.send(pid, msg, [:noconnect, :nosuspend])
          Process.send(pid, debug_msg, [:noconnect, :nosuspend])
        end

        Logger.debug(inspect(msg))
        schedule_monitor(name, state_conf)
      else
        Logger.debug("Service unregistered: #{name}")
        nil
      end

    state =
      if !is_nil(state_conf) do
        configs = state |> Map.get(name, %{})

        config = %Config{state_conf | monitor: monitor_ref}

        configs =
          configs
          |> Map.put(id, config)

        state |> Map.put(name, configs)
      else
        state
      end

    {:noreply, state}
  end

  defp schedule_monitor(name, %Config{} = config) do
    # We schedule the work to happen in config.interval seconds 
    # (written in milliseconds).
    Process.send_after(self(), {:monitor, {name, config.internal_id}}, config.interval * 1000)
  end
end

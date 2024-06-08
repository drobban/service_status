defmodule ServiceStatus do
  alias ServiceStatus.Config

  @moduledoc """
  This is the public interface of ServiceStatus
  """

  @doc """
  register

  ## Examples

      iex> ServiceStatus.register("google", %ServiceStatus.Config{
      iex> interval: 180,
      iex> url: "https://google.com",
      iex> client: self(),
      iex> internal_id: 1
      iex> })      
      :ok

  """
  @spec register(name :: any(), %Config{}) :: :ok
  def register(name, %Config{} = config) do
    GenServer.cast(ServiceStatus.Worker, {:register, %{name: name, config: config}})
  end

  @doc """
  unregister()

  ## Examples
    
      iex> ServiceStatus.unregister("google", 1)
      :ok

  """
  @type id :: integer() | nil
  @spec unregister(name :: any(), id :: id()) :: :ok
  def unregister(name, id) do
    GenServer.cast(ServiceStatus.Worker, {:unregister, %{name: name, id: id}})
  end

  @spec status() :: map()
  def status() do
    GenServer.call(ServiceStatus.Worker, :status)
  end
end

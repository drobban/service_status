defmodule ServiceStatus.Message.Status do
  @type alias :: String.t()
  @type url :: String.t()
  @type time :: integer()
  @type unit :: atom()
  @type id :: integer() | nil

  @type t :: %__MODULE__{
          alias: alias(),
          url: url(),
          response_time: time(),
          time_unit: unit(),
          ok: boolean(),
          id: id()
        }

  @enforce_keys [:alias, :url, :response_time, :time_unit, :ok]
  defstruct [:alias, :url, :response_time, :time_unit, :ok, id: nil]
end

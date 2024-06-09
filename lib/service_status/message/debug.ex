defmodule ServiceStatus.Message.Debug do
  @type message :: String.t()

  @type t :: %__MODULE__{
          message: message()
        }

  @enforce_keys [:message]
  defstruct [:message]
end

defmodule ServiceStatus.Config do
  @type url :: String.t()
  @type seconds :: integer()

  @type t :: %__MODULE__{
          url: url(),
          interval: seconds()
        }

  @enforce_keys [:url, :interval]
  defstruct [:url, :interval]
end

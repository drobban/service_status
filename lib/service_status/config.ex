defmodule ServiceStatus.Config do
  @type url :: String.t()
  @type seconds :: integer()
  @type client :: pid()

  @type t :: %__MODULE__{
          url: url(),
          interval: seconds(),
          client: client()
        }

  @enforce_keys [:url, :interval]
  defstruct [:url, :interval, client: nil]
end

defmodule ServiceStatus.Config do
  @type url :: String.t()
  @type seconds :: integer()
  @type client :: pid() | nil
  @type id :: integer() | nil

  @type t :: %__MODULE__{
          url: url(),
          interval: seconds(),
          client: client(),
          internal_id: id()
        }

  @enforce_keys [:url, :interval]
  defstruct [:url, :interval, client: nil, internal_id: nil]
end

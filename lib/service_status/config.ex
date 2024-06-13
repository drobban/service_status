defmodule ServiceStatus.Config do
  @type url :: String.t()
  @type seconds :: integer()
  @type client :: pid() | nil
  @type id :: integer() | nil
  @type monitor :: reference()

  @type t :: %__MODULE__{
          url: url(),
          interval: seconds(),
          client: client(),
          internal_id: id(),
          monitor: monitor()
        }

  @enforce_keys [:url, :interval]
  defstruct [:url, :interval, monitor: nil, client: nil, internal_id: nil]
end

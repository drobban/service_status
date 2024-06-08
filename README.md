# ServiceStatus

Monitors registered web-services.

supply url and interval given in seconds and you will recieve events informing about status.

## Installation

```elixir
def deps do
  [
    {:service_status, git: "git@github.com:drobban/service_status.git", ref: "9cb5b18b1c81a"}
  ]
end
```

## Example

```elixir

      iex> ServiceStatus.register("google", %ServiceStatus.Config{
      iex> interval: 180,
      iex> url: "https://google.com",
      iex> client: self(),
      iex> internal_id: 1
      iex> })      
      :ok

```

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
    GenServer.cast(
      ServiceStatus.Worker,
      {:register,
       %{
         name: "efs-demo",
         config: %ServiceStatus.Config{
           interval: 60,
           url: "https://efs-demo.conrock.se",
           client: self()
         }
       }}
    )
```

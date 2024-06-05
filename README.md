# ServiceStatus

Monitors registered web-services.

supply url and interval given in seconds and you will recieve events informing about status.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `service_status` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:service_status, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/service_status>.

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

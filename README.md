# SleekFlowTodo
## Requirements

This application requires:
- Erlang 27.3
- Elixir 1.18.3

You can use a tool like [asdf](https://asdf-vm.com/) with the included `.tool-versions` file to automatically install the correct versions.

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


## generate the documentation
"""
mix docs
"""

## SSH Into Remote Console
"""
fly ssh console --pty -C "/app/bin/sleekflow_todo remote"
"""

:inet_res.lookup(~c"todo-snowy-voice-3808.internal", :in, :aaaa) |> Enum.map(&to_string(:inet.ntoa(&1)))

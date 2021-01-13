# Class

[![ci](https://github.com/clszzyh/class/workflows/ci/badge.svg)](https://github.com/clszzyh/class/actions)
[![Hex.pm](https://img.shields.io/hexpm/v/class)](http://hex.pm/packages/class)
[![Hex.pm](https://img.shields.io/hexpm/dt/class)](http://hex.pm/packages/class)
[![Documentation](https://img.shields.io/badge/hexdocs-latest-blue.svg)](https://hexdocs.pm/class/readme.html)


<!-- MDOC -->

## Usage

```elixir
defmodule Person do
  use Class

  var :name, String.t(), enforce: true
  var :age, non_neg_integer(), default: 0

  @impl true
  def initialize(%{name: "foo"} = args) do
    %{args | name: "bar"}
  end
end
```

<!-- MDOC -->

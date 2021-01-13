defmodule Person do
  @moduledoc false
  use Class

  var :name, String.t(), enforce: true
  var :age, non_neg_integer(), default: 0

  def initialize(%{name: "foo"} = args), do: %{args | name: "bar"}
end

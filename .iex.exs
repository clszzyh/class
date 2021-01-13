defmodule Person do
  use Class

  var :name, String.t(), enforce: true
  var :age, non_neg_integer(), default: 0
end

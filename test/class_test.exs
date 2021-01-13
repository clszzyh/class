defmodule ClassTest do
  use ExUnit.Case
  doctest Class

  test "person" do
    assert Person.__meta__()[:enforce_keys] == [:name]
    assert Person.__meta__()[:vars] == [age: 0, name: nil]
    assert [age: {_, _, _}, name: {_, _, _}] = Person.__meta__()[:types]
    assert Person.new(%{name: "bar"}) == %Person{name: "bar", age: 0}
    assert Person.new(%{name: "foo"}) == %Person{name: "bar", age: 0}

    assert_raise ArgumentError,
                 "the following keys must also be given when building struct Person: [:name]",
                 fn ->
                   Person.new()
                 end

    assert {:docs_v1, _, :elixir, _, _, _, [_ | _]} = Code.fetch_docs(Person)

    assert {:ok, [_ | _]} = Code.Typespec.fetch_types(Person.Behaviour)
    {:ok, types} = Code.Typespec.fetch_types(Person)
    assert [_ | _] = types

    # IO.inspect(Code.Typespec.fetch_specs(PersonA.Behaviour))
  end
end

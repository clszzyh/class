defmodule Class do
  @external_resource readme = Path.join([__DIR__, "../README.md"])
  @moduledoc readme |> File.read!() |> String.split("<!-- MDOC -->") |> Enum.fetch!(1)

  @version Mix.Project.config()[:version]
  def version, do: @version

  defmacro __using__(_opt) do
    quote do
      import unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :__vars__, accumulate: true)
      Module.register_attribute(__MODULE__, :__types__, accumulate: true)
      Module.register_attribute(__MODULE__, :__enforce_keys__, accumulate: true)

      def new(args \\ %{}), do: struct!(__MODULE__, __MODULE__.initialize(args))

      unless Module.get_attribute(__MODULE__, :moduledoc) do
        @moduledoc """
        See `#{unquote(__MODULE__)}`
        """
      end

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    [
      compile_struct(env),
      compile_behaviour(env)
    ]
  end

  defp compile_struct(_env) do
    quote bind_quoted: [mod: __MODULE__] do
      module_types =
        for {name, type} <- @__types__ do
          @type unquote({name, [], Elixir}) :: unquote(type)
          {name, {name, [], []}}
        end

      @enforce_keys @__enforce_keys__
      defstruct @__vars__
      @type t :: %__MODULE__{unquote_splicing(module_types)}

      def __meta__, do: %{vars: @__vars__, types: @__types__, enforce_keys: @__enforce_keys__}

      Module.delete_attribute(__MODULE__, :__vars__)
      Module.delete_attribute(__MODULE__, :__types__)
      Module.delete_attribute(__MODULE__, :__enforce_keys__)
    end
  end

  defp compile_behaviour(_env) do
    quote do
      defmodule Behaviour do
        @moduledoc false
        @type initial_args :: map()
        @type initial_result :: map()

        @callback initialize(initial_args) :: initial_result
      end

      @behaviour Behaviour

      @impl true
      def initialize(map), do: map

      defoverridable Behaviour
    end
  end

  @doc """
  Defines a field, taken from https://github.com/ejpcmac/typed_struct/blob/master/lib/typed_struct.ex#L514-L532

  ## Example

      # A field named :example of type String.t()
      field :example, String.t()

  ## Options

    * `default` - sets the default value for the field
    * `enforce` - if set to true, enforces the field and makes its type
      non-nullable
  """
  defmacro var(name, type, opts \\ []) do
    quote bind_quoted: [name: name, opts: opts, mod: __MODULE__, type: Macro.escape(type)] do
      mod.__var__(__MODULE__, name, type, opts)
    end
  end

  @doc false
  def __var__(mod, name, type, opts) when is_atom(name) do
    if mod |> Module.get_attribute(:__vars__) |> Keyword.has_key?(name) do
      raise ArgumentError, "the field #{inspect(name)} is already set"
    end

    has_default? = Keyword.has_key?(opts, :default)
    nullable? = !has_default? && !!opts[:enforce]

    Module.put_attribute(mod, :__vars__, {name, opts[:default]})
    Module.put_attribute(mod, :__types__, {name, type_for(type, nullable?)})
    if opts[:enforce], do: Module.put_attribute(mod, :__enforce_keys__, name)
  end

  def __var__(_mod, name, _type, _opts) do
    raise ArgumentError, "a field name must be an atom, got #{inspect(name)}"
  end

  defp type_for(type, false), do: type
  defp type_for(type, _), do: quote(do: unquote(type) | nil)
end

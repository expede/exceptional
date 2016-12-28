defmodule Exceptional.Raise do
  @moduledoc ~S"""
  Raise an exception if one has been propagated, otherwise continue

  ## Convenience `use`s

  Everything:

      use Exceptional.Raise

  Only named functions (`raise_or_continue!`):

      use Exceptional.Raise, only: :named_functions

  Only operators (`>>>`):

      use Exceptional.Raise, only: :operators

  """


  defmacro __using__(only: :named_functions) do
    quote do
      import unquote(__MODULE__), except: [>>>: 2]
    end
  end

  defmacro __using__(only: :operators) do
    quote do
      import unquote(__MODULE__), only: [>>>: 2]
    end
  end

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc ~S"""
  `raise` if an exception, otherwise continue computation.

  ## Examples

      iex> use Exceptional.Raise
      ...> raise_or_continue!(1, fn x -> x + 1 end.())
      2

      iex> use Exceptional.Raise
      ...> %ArgumentError{message: "raise me"}
      ...> |> raise_or_continue!(fn x -> x + 1 end.())
      ** (ArgumentError) raise me

  """
  @lint {Credo.Check.Design.AliasUsage, false}
  defmacro raise_or_continue!(maybe_exception, continue) do
    quote do
      require Exceptional.Control
      Exceptional.Control.branch unquote(maybe_exception),
        value_do: unquote(continue),
        exception_do: fn exception -> raise(exception) end.()
    end
  end

  @doc ~S"""
  An operator alias of `raise_or_continue!`

  ## Examples

      iex> use Exceptional.Raise
      ...> 1 >>> fn x -> x + 1 end.()
      2

      iex> use Exceptional.Raise
      ...> %ArgumentError{message: "raise me"} >>> fn x -> x + 1 end.()
      ** (ArgumentError) raise me

  """
  @lint {Credo.Check.Design.AliasUsage, false}
  defmacro maybe_exception >>> continue do
    quote do
      require Exceptional.Control
      Exceptional.Control.branch unquote(maybe_exception),
        value_do: unquote(continue),
        exception_do: fn exception -> raise(exception) end.()
    end
  end

  @doc ~S"""
  Raise an exception, otherwise return plain value

  ## Examples

      iex> ensure!([1, 2, 3])
      [1, 2, 3]

      iex> ensure!(%ArgumentError{message: "raise me"})
      ** (ArgumentError) raise me

  """
  def ensure!(maybe_exception) do
    if Exception.exception?(maybe_exception) do
      raise maybe_exception
    else
      maybe_exception
    end
  end

  @doc ~S"""
  Define a function and automatically generate a variant that raises

  ## Examples

      iex> defmodule Foo do
      ...>   use Exceptional
      ...>
      ...>   def! foo(a), do: a
      ...> end
      ...>
      ...> Foo.foo([1, 2, 3])
      [1, 2, 3]

      iex> defmodule Bar do
      ...>   use Exceptional
      ...>
      ...>   def! bar(a), do: a
      ...> end
      ...>
      ...> Bar.bar(%ArgumentError{message: "raise me"})
      %ArgumentError{message: "raise me"}

      iex> defmodule Baz do
      ...>   use Exceptional
      ...>
      ...>   def! baz(a), do: a
      ...> end
      ...>
      ...> Baz.baz!([1, 2, 3])
      [1, 2, 3]

      iex> defmodule Quux do
      ...>   use Exceptional
      ...>
      ...>   def! quux(a), do: a
      ...> end
      ...>
      ...> Quux.quux!(%ArgumentError{message: "raise me"})
      ** (ArgumentError) raise me

  """
  defmacro def!(head, do: body) do
    {name, ctx, args} = head
    variant = {String.to_atom("#{name}!"), ctx, args}

    quote do
      def unquote(head), do: unquote(body)
      def unquote(variant), do: unquote(body) |> ensure!
    end
  end
end

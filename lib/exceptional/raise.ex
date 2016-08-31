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
      require unquote(__MODULE__)
      import unquote(__MODULE__), except: [>>>: 2]
    end
  end

  defmacro __using__(only: :operators) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__), only: [>>>: 2]
    end
  end

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
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
end

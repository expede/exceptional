defmodule Exceptional.Value do
  @moduledoc ~S"""
  Provide an escape hatch for propagating unraised exceptions

  ## Convenience `use`s

  Everything:

      use Exceptional.Value

  Only named functions (`exception_or_continue`):

      use Exceptional.Value, only: :named_functions

  Only operators (`~>`):

      use Exceptional.Value, only: :operators

  """

  defmacro __using__(only: :named_functions) do
    quote do
      import unquote(__MODULE__), except: [~>: 2]
    end
  end

  defmacro __using__(only: :operators) do
    quote do
      import unquote(__MODULE__), only: [~>: 2]
    end
  end

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc ~S"""
  If an exception, return the exception, otherwise continue computation.
  Essentially an `Either` construct for `Exception`s.

  Note that this does not catch `raise` or `throw`s. If you want that behaviour,
  please see `Exceptional.Rescue`.

  ## Examples

      iex> 1 |> exception_or_continue(fn value -> value * 100 end.())
      100

      iex> %ArgumentError{message: "exception handled"}
      ...> |> exception_or_continue(fn value -> value * 100 end.())
      %ArgumentError{message: "exception handled"}

      iex> %ArgumentError{message: "exception handled"}
      ...> |> exception_or_continue(fn x -> x + 1 end.())
      ...> |> exception_or_continue(fn y -> y - 10 end.())
      %ArgumentError{message: "exception handled"}

      iex> %ArgumentError{message: "exception not caught"}
      ...> |> raise
      ...> |> exception_or_continue(fn value -> value * 100 end.())
      ** (ArgumentError) exception not caught

      iex> Enum.fetch!([], 9) |> exception_or_continue(fn v -> v * 10 end.())
      ** (Enum.OutOfBoundsError) out of bounds error

  """
  @lint {Credo.Check.Design.AliasUsage, false}
  @spec exception_or_continue(Exception.t | any, fun) :: Exception.t | any
  defmacro exception_or_continue(maybe_exception, continue) do
    quote do
      require Exceptional.Control
      Exceptional.Control.branch unquote(maybe_exception),
        value_do: unquote(continue),
        exception_do: fn exception -> exception end.()
    end
  end

  @doc ~S"""
  Operator alias for `exception_or_continue`

  ## Examples

      iex> 1 ~> fn value -> value * 100 end.()
      100

      iex> exception = %Enum.OutOfBoundsError{message: "exception"}
      ...> exception ~> fn x -> x + 1 end.()
      %Enum.OutOfBoundsError{message: "exception"}

      ...> exception
      ...> ~> fn x -> x + 1 end.()
      ...> ~> fn y -> y - 10 end.()
      %Enum.OutOfBoundsError{message: "exception"}

      ...> raise(exception) ~> fn x -> x + 1 end.()
      ** (Enum.OutOfBoundsError) out of bounds error

      iex> Enum.fetch!([], 9) ~> fn x -> x + 1 end.()
      ** (Enum.OutOfBoundsError) out of bounds error

  """
  @lint {Credo.Check.Design.AliasUsage, false}
  defmacro maybe_exception ~> continue do
    quote do
      require Exceptional.Control
      Exceptional.Control.branch unquote(maybe_exception),
         value_do: unquote(continue),
         exception_do: fn exception -> exception end.()
    end
  end
end

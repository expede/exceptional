defmodule Exceptional.Value do

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__), only: [~>: 2]
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

      iex> exception = %Enum.OutOfBoundsError{message: "exception"}
      ...> exception |> exception_or_continue(fn value -> value * 100 end.())
      %Enum.OutOfBoundsError{message: "exception"}

      ...> exception
      ...> |> exception_or_continue(fn x -> x + 1 end.())
      ...> |> exception_or_continue(fn y -> y - 10 end.())
      %Enum.OutOfBoundsError{message: "exception"}

      ...> raise(exception) |> exception_or_continue(fn value -> value * 100 end.())
      ** (Enum.OutOfBoundsError) out of bounds error

      iex> Enum.fetch!([], 9) |> exception_or_continue(fn value -> value * 100 end.())
      ** (Enum.OutOfBoundsError) out of bounds error

  """
  @spec exception_or_continue(Exception.t | any, fun) :: Exception.t | any
  defmacro exception_or_continue(maybe_exception, continue) do
    quote do
      use Exceptional.Control

      Exceptional.Control.branch unquote(maybe_exception),
        value_do: unquote(continue),
        exception_do: fn x -> x end.()
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
  defmacro maybe_exception ~> continue do
    quote do
      use Exceptional.Control

      Exceptional.Control.branch unquote(maybe_exception),
         value_do: unquote(continue),
         exception_do: fn x -> x end.()
    end
  end
end

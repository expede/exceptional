defmodule Exceptional.Control do
  @moduledoc ~S"""
  Exception control flow

  ## Convenience `use`s

  Everything:

      use Exceptional.Control

  """

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc ~S"""
  Branch on if the value is an `Exception`, applying the associated function for
  that case. Does not catch thrown exceptions.

  ## Examples

      iex> use Exceptional.Control
      ...> branch 1,
      ...>   value_do: fn v -> v + 1 end.(),
      ...>   exception_do: fn ex -> ex end.()
      2

      iex> use Exceptional.Control
      ...> branch ArgumentError.exception("error message"),
      ...>   value_do: fn v -> v end.(),
      ...>   exception_do: fn %{message: msg} -> msg end.()
      "error message"

      iex> use Exceptional.Control
      ...> branch Enum.fetch!([], 99),
      ...>   value_do: fn v -> v + 1 end.(),
      ...>   exception_do: fn ex -> ex end.()
      ** (Enum.OutOfBoundsError) out of bounds error

  """
  defmacro branch(maybe_exception, [value_do: value_do, exception_do: exception_do]) do
    quote do
      maybe_exc = unquote(maybe_exception)
      if Exception.exception?(maybe_exc) do
        maybe_exc |> unquote(exception_do)
      else
        maybe_exc |> unquote(value_do)
      end
    end
  end

  @doc ~S"""
  Alias for `Exceptional.Control.branch`

  ## Examples

      iex> use Exceptional.Control
      ...> if_exception 1, do: fn ex -> ex end.(), else: fn v -> v + 1 end.()
      2

      iex> use Exceptional.Control
      ...> if_exception ArgumentError.exception("error message") do
      ...>   fn %{message: msg} -> msg end.()
      ...> else
      ...>   fn v -> v end.()
      ...> end
      "error message"


      iex> use Exceptional.Control
      ...> ArgumentError.exception("error message")
      ...> |> if_exception do
      ...>   fn %{message: msg} -> msg end.()
      ...> else
      ...>   fn v -> v end.()
      ...> end
      "error message"

  """
  defmacro if_exception(maybe_exception, do: exception_do, else: value_do) do
    quote do
      maybe_exc = unquote(maybe_exception)
      if Exception.exception?(maybe_exc) do
        maybe_exc |> unquote(exception_do)
      else
        maybe_exc |> unquote(value_do)
      end
    end
  end
end

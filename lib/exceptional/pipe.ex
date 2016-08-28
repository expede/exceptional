defmodule Exceptional.Pipe do
  @moduledoc ~S"""
  This module overloads the basic `|>` operator, and as such should be used
  with _extreme caution_ (if ever).
  """

  defmacro __using__(_) do
    quote do
      import Kernel, except: [|>: 2]

      require unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end

  import Kernel, except: [|>: 2]

  @doc ~S"""
  ## Examples

      iex> use Exceptional.Pipe
      ...> 1 |> fn x -> x * 100 end.()
      100

      iex> use Exceptional.Pipe
      ...> ArgumentError.exception("plain error")
      ...> |> fn x -> x * 100 end.()
      %ArgumentError{message: "plain error"}

  """
  defmacro maybe_exception |> continue do
    quote do
      use Exceptional.Value
      unquote(maybe_exception) ~> unquote(continue)
    end
  end
end

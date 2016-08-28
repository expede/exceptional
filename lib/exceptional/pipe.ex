defmodule Exceptional.Pipe do
  @defmodule ~S"""
  This module overloads the basic `|>` operator, and as such should be used
  with _extreme caution_.
  """

  defmacro __using__(_) do
    import Kernel, except: [|>: 2]

    require __MODULE__
    import __MODULE__
  end

  defmacro a |> b do
    a |> b
  end
end

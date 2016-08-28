defmodule Exceptional.Pipe do
  # @defmodule ~S"""
  # This module overloads the basic `|>` operator, and as such should be used
  # with _extreme caution_.
  # """

  # defmacro __using__(_) do
  #   quote do
  #     import Kernel, except: [|>: 2]

  #     require unquote(__MODULE__)
  #     import unquote(__MODULE__)
  #   end
  # end

  # import Kernel, except: [|>: 2]
  # import Exceptional.Value

  # def a |> b, do: a ~> b
end

defmodule Exceptional.Raise do
  # use Exceptional.Control

  # defdelegate a >>> b, to: __MODULE__, as: :raise_or_continue

  # @doc ~S"""
  # `raise` if an exception, otherwise continue computation.
  # """
  # @spec raise_or_continue(Exception.t | any, fun) :: Exception.t | any
  # def raise_or_continue(maybe_exception, continue) do
  #   Control.branch maybe_exception, value_do: continue, exception_do: &Kernel.raise/1
  # end
end

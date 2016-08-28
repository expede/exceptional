defmodule Exceptional do
  @moduledoc ~S"""
  Top-level `use` aliases"

  In almost all cases, you want:

      use Exceptional

  If you like to live extremely dangerously. This is _not recommended_.
  Please be certain that you want to override the standard lib before using.

      use Exceptional :overload_pipe

  """

  defmacro __using__(:overload_pipe) do
    quote do
      use Exceptional.Pipe
      use Exceptional
    end
  end

  defmacro __using__(_) do
    quote do
      import Exceptional.{Value, Raise, Rescue, TaggedStatus}
    end
  end
end

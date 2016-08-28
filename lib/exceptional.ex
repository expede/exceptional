defmodule Exceptional do
  defmacro __using__(:pipe) do
    quote do
      use Exceptional.Pipe
      use Exceptional
    end
  end

  defmacro __using__(_) do
    quote do
      import Exceptional.{Value, Raise, TaggedStatus}
    end
  end
end

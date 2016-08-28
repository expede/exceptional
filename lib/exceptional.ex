defmodule Exceptional do
  @moduledoc "Top-level `use` aliases"

  defmacro __using__(:pipe) do
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

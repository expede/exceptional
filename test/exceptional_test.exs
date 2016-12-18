defmodule Exceptional.PipeTest do
  use ExUnit.Case

  doctest Exceptional.Control, [import: true]
  # doctest Exceptional.Pipe, [import: true]
  doctest Exceptional.Raise, [import: true]
  doctest Exceptional.TaggedStatus, [import: true]
  doctest Exceptional.Unraise, [import: true]
  doctest Exceptional.Value, [import: true]
end

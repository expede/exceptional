defmodule Exceptional.PipeTest do
  use ExUnit.Case

  doctest Exceptional.Block, [import: true]
  doctest Exceptional.Control, [import: true]
  doctest Exceptional.Normalize, [import: true]
  doctest Exceptional.Pipe, [import: true]
  doctest Exceptional.Raise, [import: true]
  doctest Exceptional.Safe, [import: true]
  doctest Exceptional.TaggedStatus, [import: true]
  doctest Exceptional.Value, [import: true]
end

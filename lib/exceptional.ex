defmodule Exceptional do
  @moduledoc ~S"""
  Top-level `use` aliases

  In almost all cases, you want:

      use Exceptional

  If you only want the operators:

      use Exceptional, only: :operators

  If you only want named functions:

      use Exceptional, only: :named_functions

  If you like to live extremely dangerously. This is _not recommended_.
  Please be certain that you want to override the standard lib before using.

      use Exceptional, include: :overload_pipe

  """

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts]  do
      use Exceptional.Control, opts
      use Exceptional.Normalize, opts
      use Exceptional.Pipe, opts
      use Exceptional.Raise, opts
      use Exceptional.Safe, opts
      use Exceptional.TaggedStatus, opts
      use Exceptional.Value, opts
    end
  end
end

defmodule Exceptional.Control do

  defmacro __using__(_) do
    require __MODULE__
    import __MODULE__
  end

  @doc ~S"""
  If an exception, return the exception, otherwise continue computation.
  Essentially an `Either` construct for `Exception`s.
  """
  @spec value_or_exception(Exception.t | any, fun) :: Exception.t | any
  defmacro value_or_exception(check_value, continue) do
    quote do
      value = unquote(check_value)
      if Exception.exception?(value), do: value, else: value |> unquote(continue)
    end
  end

  defmacro value ~> continue do
    quote do: value_or_exception(unquote(value), unquote(continue))
  end
end

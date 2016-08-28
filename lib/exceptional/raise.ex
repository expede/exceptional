defmodule Exceptional.Raise do

  defmacro __using__(_) do
    require __MODULE__
    import __MODULE__
  end

  defdelegate a >>> b, to: :raise_or_continue

  @doc ~S"""
  `raise` if an exception, otherwise continue computation.
  """
  @spec raise_or_continue(Exception.t | any, fun) :: Exception.t | any
  defmacro raise_or_continue(check_value, continue) do
    quote do
      value = unquote(check_value)
      if Exception.exception?(value) do
        raise(value)
      else
        value |> unquote(continue)
      end
    end
  end
end

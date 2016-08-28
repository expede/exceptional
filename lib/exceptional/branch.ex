defmodule Exceptional.Branch do
  def branch(maybe_exception, value_do, exception_do) do
    quote do
      value = unquote(maybe_exception)
      if Exception.exception?(value) do
        value |> unquote(exception_do)
      else
        value |> unquote(value_do)
      end
    end
  end
end

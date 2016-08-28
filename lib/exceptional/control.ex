defmodule Exceptional.Control do
  @defmodule "Internal module for control flow"

  defmacro __using__(_) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end

  defmacro branch(maybe_exception, [value_do: value_do, exception_do: exception_do]) do
    quote do
      maybe_exc = unquote(maybe_exception)
      if Exception.exception?(maybe_exc) do
        maybe_exc |> unquote(exception_do)
      else
        maybe_exc |> unquote(value_do)
      end
    end
  end
end

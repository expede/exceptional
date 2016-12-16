defmodule Exceptional.Unraise do
  @moduledoc ~S"""
  """

  defmacro unraise(dangerous_fun) do
    quote do
      {:arity, arity} = :erlang.fun_info(dangerous_fun, :arity)
      args = generate_args(arity)

      fn unquote_splicing(arity) ->
        try do
          dangerous_fun(unquote_splicing(arity))
        rescue
          exception -> exception
        end
      end
    end
  end

  defp generate_args(arity) do
    97 # 'a'
    |> Stream.unfold(fn a -> {a, [97 | a]} end)
    |> Enum.take(arity)
  end
end

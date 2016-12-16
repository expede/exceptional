defmodule Exceptional.Unraise do
  @moduledoc ~S"""
  """

  defmacro unraise(dangerous_fun) do
    quote do
      {:arity, arity} = :erlang.fun_info(unquote(dangerous_fun), :arity)
      args = generate_args(arity)

      fn unquote_splicing(quote(args)) ->
        try do
          unquote(dangerous_fun)(unquote_splicing(args))
        rescue
          exception -> exception
        end
      end
    end
  end

  def generate_args(arity) do
    [97]
    |> Stream.unfold(fn acc -> {acc, [97 | acc]} end)
    |> Enum.take(arity)
    |> Enum.map(&List.to_atom/1)
  end
end

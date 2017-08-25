defmodule Exceptional.Block do
  @moduledoc ~S"""
  Convenience functions to wrap a block of calls similar to `with`.

  ## Convenience `use`s

  Everything:

      use Exceptional.Block

  """

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc ~S"""
  This specifies a block that is tested as normal similar to Elixir's `with`.

  This will auto-normalize every return value, so expect a raw `value` return,
  not something like `{:ok, value}` when using `<-`.  `=` is unwrapped and
  unhandled.

  ## Examples

      iex> use Exceptional.Block
      ...> block do
      ...>   _ <- {:ok, 2}
      ...> end
      2

      iex> use Exceptional.Block
      ...> block do
      ...>   a <- {:ok, 2}
      ...>   b = a * 2
      ...>   c <- {:ok, b * 2}
      ...>   c * 2
      ...> end
      16

      iex> use Exceptional.Block
      ...> block do
      ...>   a <- {:ok, 2}
      ...>   b = a * 2
      ...>   _ = 42
      ...>   c <- {:error, "Failed: #{b}"}
      ...>   c * 2
      ...> end
      %ErlangError{original: "Failed: 4"}

      iex> use Exceptional.Block
      ...> block do
      ...>   a <- {:ok, 2}
      ...>   b = a * 2
      ...>   _ = 42
      ...>   c <- {:error, "Failed: #{b}"}
      ...>   c * 2
      ...> else
      ...>   _ -> {:error, "unknown error"}
      ...> end
      %ErlangError{original: "unknown error"}

      iex> use Exceptional.Block
      ...> conversion_fun = fn
      ...>   {:blah, reason} -> %ErlangError{original: "Blah: #{reason}"}
      ...>   e -> e
      ...> end
      ...> block conversion_fun: conversion_fun do
      ...>   a <- {:ok, 2}
      ...>   b = a * 2
      ...>   _ = 42
      ...>   c <- {:blah, "Failed: #{b}"}
      ...>   c * 2
      ...> else
      ...>   _ -> {:error, "unknown error"}
      ...> end
      %ErlangError{original: "unknown error"}

  """
  defmacro block(opts, bodies \\ []) do
    opts = bodies ++ opts
    gen_block(opts)
  end

  @doc ~S"""
  The auto-throwing version of `block`, will raise it's final error.

  ## Examples

      iex> use Exceptional.Block
      ...> block! do
      ...>   a <- {:ok, 2}
      ...>   b = a * 2
      ...>   _ = 42
      ...>   c <- {:error, "Failed: #{b}"}
      ...>   c * 2
      ...> end
      ** (ErlangError) Erlang error: "Failed: 4"

  """
  defmacro block!(opts, bodies \\ []) do
    opts = bodies ++ opts
    body = gen_block(opts)
    quote do
      Exceptional.Raise.ensure!(unquote(body))
    end
  end

  defp gen_block(opts) do
    {:__block__, _meta, do_body} = wrap_block(opts[:do] || throw "Must specify a `do` body clause with at least one expression!")
    conversion_fun_ast =
      case opts[:conversion_fun] do
        nil -> quote do fn x -> x end end
        call -> call
      end
    conversion_fun = gen_unique_var("$conversion_fun")
    else_fun_ast =
      case opts[:else] do
        nil -> quote do fn x -> x end end
        clauses ->
          # credo:disable-for-lines:7 /Alias|Nesting/
          quote do
            fn x ->
              x
              |> case do
                unquote(clauses)
              end
              |> Exceptional.Normalize.normalize(unquote(conversion_fun))
            end
          end
      end
    else_fun = gen_unique_var("$else_fun")
    body = gen_block_body(do_body, conversion_fun, else_fun)
    quote generated: true do
      unquote(conversion_fun) = unquote(conversion_fun_ast)
      unquote(else_fun) = unquote(else_fun_ast)
      unquote(body)
    end
  end

  defp wrap_block({:__block__, _, _} = ast), do: ast
  defp wrap_block(ast), do: {:__block__, [], [ast]}

  defp gen_block_body(exprs, conversion_fun, else_fun)
  defp gen_block_body([{:<-, meta, [binding, bound]} | exprs], conversion_fun, else_fun) do
    value = Macro.var(:"$val", __MODULE__)
    next =
      case exprs do
        [] -> value
        _ -> gen_block_body(exprs, conversion_fun, else_fun)
      end
    {call, gen_meta, args} =
      quote generated: true do
        # credo:disable-for-lines:1 Credo.Check.Design.AliasUsage
        case Exceptional.Normalize.normalize(unquote(bound), unquote(conversion_fun)) do
          %{__exception__: _} = unquote(value) -> unquote(else_fun).(unquote(value))
          unquote(binding) = unquote(value) -> unquote(next)
          unquote(value) -> unquote(else_fun).(unquote(value))
        end
      end
    {call, meta ++ gen_meta, args}
  end
  defp gen_block_body([expr | exprs], conversion_fun, else_fun) do
    value = gen_unique_var(:"$val")
    next =
      case exprs do
        [] -> value
        _ -> gen_block_body(exprs, conversion_fun, else_fun)
      end
    quote generated: true do
      unquote(value) = unquote(expr)
      unquote(next)
    end
  end
  defp gen_block_body(exprs, _conversion_fun, _else_fun) do
    throw {:UNHANDLED_EXPRS, exprs}
  end

  defp gen_unique_var(name) do
    id = Process.get(__MODULE__, 0)
    Process.put(__MODULE__, id + 1)
    name =
      if id === 0 do
        String.to_atom(name)
      else
        String.to_atom("#{name}_#{id}")
      end
    Macro.var(name, __MODULE__)
  end

end

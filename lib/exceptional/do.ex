defmodule Exceptional.Do do

  defmacro exceptionally([as: module], do: input) do
    Witchcraft.Foldable.right_fold(Enum.reverse(AST.normalize(input)), fn
      (ast = {:<-, ctx, inner = [old_left = {lt, lc, lb}, right]}, acc) ->
        left = {lt, lc, nil}
      case acc do
        {:fn, _, _} ->
          quote do: unquote(right) >>> fn unquote(left) -> unquote(acc).(unquote(left)) end

        acc ->
          quote do: unquote(right) >>> fn unquote(left) -> unquote(acc) end
      end

      (ast, acc) -> quote do: bind_forget(unquote(ast), unquote(acc))
    end)
  end

  defmacro exceptionaly(do: input) do

  end
end

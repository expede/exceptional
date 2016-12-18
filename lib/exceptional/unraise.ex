defmodule Exceptional.Unraise do
  @moduledoc ~S"""
  """

  defdelegate lower(dangeroud_fun),          to: __MODULE__, as: :unraise
  defdelegate lower(dangeroud_fun, dynamic), to: __MODULE__, as: :unraise

  def unraise(dangerous_fun) do
    safe_fun = unraise(dangerous_fun, :dynamic)
    {:arity, arity} = :erlang.fun_info(dangerous_fun, :arity)

    case arity do
      0 -> fn ()                 -> safe_fun.([]) end
      1 -> fn (a)                -> safe_fun.([a]) end
      2 -> fn (a, b)             -> safe_fun.([a, b]) end
      3 -> fn (a, b, c)          -> safe_fun.([a, b, c]) end
      4 -> fn (a, b, c, d)       -> safe_fun.([a, b, c, d]) end
      5 -> fn (a, b, c, d, e)    -> safe_fun.([a, b, c, d, e]) end
      6 -> fn (a, b, c, d, e, f) -> safe_fun.([a, b, c, d, e, f]) end
    end
  end

  def unraise(dangerous_fun, :dynamic) do
    fn arg_list ->
      try do
        Kernel.apply(dangerous_fun, arg_list)
      rescue
        exception -> exception
      end
    end
  end
end

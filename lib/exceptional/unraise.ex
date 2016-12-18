defmodule Exceptional.Unraise do
  @moduledoc ~S"""
  """

  defdelegate lower(dangeroud_fun),          to: __MODULE__, as: :unraise
  defdelegate lower(dangeroud_fun, dynamic), to: __MODULE__, as: :unraise

  @doc ~S"""
  Create a version of a function that does not raise exception. It will return the exception struct instead.

  With the `:dynamic` option passed, it takes a list of arguments (like `Kernel.apply`)

      iex> toothless = unraise(&Enum.fetch!/2, :dynamic)
      ...> toothless.([[1,2,3], 1])
      2

      iex> toothless = unraise(&Enum.fetch!/2, :dynamic)
      ...> toothless.([[1,2,3], 999])
      %Enum.OutOfBoundsError{message: "out of bounds error"}

  It also works on functions that wouldn't normally raise

      iex> same = unraise(&Enum.fetch/2, :dynamic)
      ...> same.([[1,2,3], 1])
      {:ok, 2}

      iex> same = unraise(&Enum.fetch/2, :dynamic)
      ...> same.([[1,2,3], 999])
      :error

  """
  @spec unraise(fun, :dynamic) :: fun
  def unraise(dangerous_fun, :dynamic) do
    fn arg_list ->
      try do
        Kernel.apply(dangerous_fun, arg_list)
      rescue
        exception -> exception
      end
    end
  end

  @doc ~S"""
  Create a version of a function that does not raise exception.
  When called, it will return the exception struct instead of raising exceptions.
  All other behaviour is normal.

  The returned anonymous function will have the same arity as the wrapped function.
  For technical reasons, the maximum arity is 9 (like most sane functions).

  If you need a higher arity, please use the `:dynamic` option in `unraise/2`.

      iex> toothless = unraise(&Enum.fetch!/2)
      ...> [1,2,3] |> toothless.(1)
      2

      iex> toothless = unraise(&Enum.fetch!/2)
      ...> [1,2,3] |> toothless.(999)
      %Enum.OutOfBoundsError{message: "out of bounds error"}

  It also works on functions that wouldn't normally raise

      iex> same = unraise(&Enum.fetch/2)
      ...> [1,2,3] |> same.(1)
      {:ok, 2}

      iex> same = unraise(&Enum.fetch/2)
      ...> [1,2,3] |> same.(999)
      :error

  """
  @spec unraise(fun) :: fun
  def unraise(dangerous_fun) do
    safe_fun = unraise(dangerous_fun, :dynamic)
    {:arity, arity} = :erlang.fun_info(dangerous_fun, :arity)

    case arity do
      0 -> fn () -> safe_fun.([]) end
      1 -> fn (a) -> safe_fun.([a]) end
      2 -> fn (a, b) -> safe_fun.([a, b]) end
      3 -> fn (a, b, c) -> safe_fun.([a, b, c]) end
      4 -> fn (a, b, c, d) -> safe_fun.([a, b, c, d]) end
      5 -> fn (a, b, c, d, e) -> safe_fun.([a, b, c, d, e]) end
      6 -> fn (a, b, c, d, e, f) -> safe_fun.([a, b, c, d, e, f]) end
      7 -> fn (a, b, c, d, e, f, g) -> safe_fun.([a, b, c, d, e, f]) end
      8 -> fn (a, b, c, d, e, f, g, h) -> safe_fun.([a, b, c, d, e, f]) end
      9 -> fn (a, b, c, d, e, f, g, h, i) -> safe_fun.([a, b, c, d, e, f, g, h]) end
    end
  end
end

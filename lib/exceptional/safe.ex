defmodule Exceptional.Safe do
  @moduledoc ~S"""
  Convert a function that may `raise` into one that returns an exception struct
  """

  defdelegate lower(dangeroud_fun),          to: __MODULE__, as: :safe
  defdelegate lower(dangeroud_fun, dynamic), to: __MODULE__, as: :safe

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc ~S"""
  Create a version of a function that does not raise exception.
  It will return the exception struct instead.

  With the `:dynamic` option passed, it takes a list of arguments
  (exactly like `Kernel.apply`)

      iex> toothless = safe(&Enum.fetch!/2, :dynamic)
      ...> toothless.([[1,2,3], 1])
      2

      iex> toothless = safe(&Enum.fetch!/2, :dynamic)
      ...> toothless.([[1,2,3], 999])
      %Enum.OutOfBoundsError{message: "out of bounds error"}

  It also works on functions that wouldn't normally raise

      iex> same = safe(&Enum.fetch/2, :dynamic)
      ...> same.([[1,2,3], 1])
      {:ok, 2}

      iex> same = safe(&Enum.fetch/2, :dynamic)
      ...> same.([[1,2,3], 999])
      :error

  """
  @spec safe(fun, :dynamic) :: fun
  def safe(dangerous, :dynamic) do
    fn arg_list ->
      try do
        Kernel.apply(dangerous, arg_list)
      rescue
        exception -> exception
      end
    end
  end

  @doc ~S"""
  Create a version of a function that does not raise exception.
  When called, it will return the exception struct instead of raising it.
  All other behaviour is normal.

  The returned anonymous function will have the same arity as the wrapped one.
  For technical reasons, the maximum arity is 9 (like most sane functions).

  If you need a higher arity, please use the `:dynamic` option in `safe/2`.

      iex> toothless = safe(&Enum.fetch!/2)
      ...> [1,2,3] |> toothless.(1)
      2

      iex> toothless = safe(&Enum.fetch!/2)
      ...> [1,2,3] |> toothless.(999)
      %Enum.OutOfBoundsError{message: "out of bounds error"}

  It also works on functions that wouldn't normally raise

      iex> same = safe(&Enum.fetch/2)
      ...> [1,2,3] |> same.(1)
      {:ok, 2}

      iex> same = safe(&Enum.fetch/2)
      ...> [1,2,3] |> same.(999)
      :error

  """
  @spec safe(fun) :: fun
  @lint [
    {Credo.Check.Refactor.ABCSize, false},
    {Credo.Check.Refactor.CyclomaticComplexity, false}
  ]
  def safe(dangerous) do
    safe = safe(dangerous, :dynamic)
    {:arity, arity} = :erlang.fun_info(dangerous, :arity)

    case arity do
      0 -> fn () ->
        safe.([]) end

      1 -> fn (a) ->
        safe.([a]) end

      2 -> fn (a, b) ->
        safe.([a, b]) end

      3 -> fn (a, b, c) ->
        safe.([a, b, c]) end

      4 -> fn (a, b, c, d) ->
        safe.([a, b, c, d]) end

      5 -> fn (a, b, c, d, e) ->
        safe.([a, b, c, d, e]) end
      6 -> fn (a, b, c, d, e, f) ->
        safe.([a, b, c, d, e, f]) end

      7 -> fn (a, b, c, d, e, f, g) ->
        safe.([a, b, c, d, e, f, g]) end

      8 -> fn (a, b, c, d, e, f, g, h) ->
        safe.([a, b, c, d, e, f, g, h]) end

      9 -> fn (a, b, c, d, e, f, g, h, i) ->
        safe.([a, b, c, d, e, f, g, h, i]) end
    end
  end
end

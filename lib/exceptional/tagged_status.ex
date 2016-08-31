defmodule Exceptional.TaggedStatus do
  @moduledoc "Convert back to conventional Erlang/Elixir `{:ok, _}` tuples"

  defmacro __using__(_) do
    quote do: import unquote(__MODULE__)
  end

  @doc ~S"""
  Convert unraised exceptions to `{:error, message}`, and other values to
  `{:ok, value}`.

  ## Examples

      iex> to_tagged_status [1,2,3]
      {:ok, [1,2,3]}

      iex> Enum.OutOfBoundsError.exception("error message") |> to_tagged_status
      {:error, "error message"}

  """
  def to_tagged_status(maybe_exception) do
    case maybe_exception do
      tuple when is_tuple(tuple) ->
        tuple
        |> Tuple.to_list
        |> List.first
        |> case do
             tag when is_atom(tag) -> tuple
             _ -> {:ok, tuple}
        end

      value ->
        if Exception.exception?(value) do
          {:error, value.message}
        else
          {:ok, value}
        end
    end
  end

  @doc ~S"""
  Alias for `to_tagged_status`

  ## Examples

      iex> [1,2,3] |> ok
      {:ok, [1,2,3]}

      iex> Enum.OutOfBoundsError.exception("error message") |> ok
      {:error, "error message"}

  """
  defdelegate ok(maybe_exception),  to: __MODULE__, as: :to_tagged_status


  @doc ~S"""
  Operator alias for `to_tagged_status`

  ## Examples

      iex> ~~~[1,2,3]
      {:ok, [1,2,3]}

      iex> ~~~Enum.OutOfBoundsError.exception("error message")
      {:error, "error message"}

      iex> exc = Enum.OutOfBoundsError.exception("error message")
      ...> ~~~exc
      {:error, "error message"}

  """
  defdelegate ~~~(maybe_exception), to: __MODULE__, as: :to_tagged_status
end

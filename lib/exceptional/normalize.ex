defmodule Exceptional.Normalize do
  @moduledoc ~S"""
  Normalize values to a consistent exception struct or plain value.
  In some ways this can be seen as the opposite of `tagged_tuple`/`ok`.
  """

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc ~S"""
  Normalizes values into exceptions or plain values (no `{:error, _}` tuples).
  Some error types may not be detected; you may pass a custom converter.
  See more below.

  Normal values will simply pass through:

      iex> normalize(42)
      42

  Struct exceptions will also pass straight through:

      iex> normalize(%Enum.OutOfBoundsError{message: "out of bounds error"})
      %Enum.OutOfBoundsError{message: "out of bounds error"}

  This covers the most common tuple error cases (see examples below), but is by
  no means exhaustive.

      iex> normalize(:error)
      %ErlangError{original: nil}

      iex> normalize(:error)
      %ErlangError{original: nil}

      iex> normalize({:error, "boom"})
      %ErlangError{original: "boom"}

      iex> normalize({:error, {1, 2, 3}})
      %ErlangError{original: {1, 2, 3}}

      iex> normalize({:error, "boom with stacktrace", ["trace"]})
      %ErlangError{original: "boom with stacktrace"}

  Some errors tuples cannot be detected.
  Those cases will be returned as plain values.

      iex> normalize({:good, "tuple", ["value"]})
      {:good, "tuple", ["value"]}

  You may optionally pass a converting function as a second argument.
  This allows you to construct a variant of `normalize` that accounts for
  some custom error message(s).

      iex> {:oh_no, {"something bad happened", %{bad: :thing}}}
      ...> |> normalize(fn
      ...>   {:oh_no, {message, _}} -> %File.Error{reason: message}
      ...>   {:bang, message}       -> %File.CopyError{reason: message}
      ...>   otherwise              -> otherwise
      ...> end)
      %File.Error{reason: "something bad happened"}

      iex> {:oh_yes, {1, 2, 3}}
      ...> |> normalize(fn
      ...>   {:oh_no, {message, _}} -> %File.Error{reason: message}
      ...>   {:bang, message}       -> %File.CopyError{reason: message}
      ...>   otherwise              -> otherwise
      ...> end)
      {:oh_yes, {1, 2, 3}}

  """
  @spec normalize(any, fun) :: any
  def normalize(error_or_value, conversion_fun \\ fn x -> x end) do
    case error_or_value do
      :error           -> %ErlangError{}
      {:error}         -> %ErlangError{}
      {:error, detail} -> Exception.normalize(:error, detail)

      plain = {error_type, status, stacktrace} ->
        err = Exception.normalize(error_type, status, stacktrace)
        if Exception.exception?(err), do: err, else: plain

      {:ok, value} -> value
      value -> conversion_fun.(value)
    end
  end
end

defmodule Exceptional.Normalize do

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc ~S"""

      iex> normalize(42)
      42

      iex> normalize(%Enum.OutOfBoundsError{message: "out of bounds error"})
      %Enum.OutOfBoundsError{message: "out of bounds error"}

      iex> normalize(:error)
      %ErlangError{original: nil}

      iex> normalize({:error, "boom"})
      %ErlangError{original: "boom"}

      iex> normalize({:error, {1, 2, 3}})
      %ErlangError{original: {1, 2, 3}}

      iex> normalize({:error, "boom with stacktrace", ["trace"]})
      %ErlangError{original: "boom with stacktrace"}

      iex> normalize({:good, "tuple", ["value"]})
      {:good, "tuple", ["value"]}

  """
  @spec normalize(any) :: any
  def normalize(error_or_value) do
    case error_or_value do
      :error           -> %ErlangError{}
      {:error}         -> %ErlangError{}
      {:error, detail} -> Exception.normalize(:error, detail)

      plain = {error_type, status, stacktrace} ->
        err = Exception.normalize(error_type, status, stacktrace)
        if Exception.exception?(err), do: err, else: plain

      {:ok, value} -> value
      value -> value
    end
  end
end

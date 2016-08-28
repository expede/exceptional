defmodule Exceptional.TaggedStatus do

  defdelegate ok(maybe_exception), to: __MODULE__, as: :to_tagged_status

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
end

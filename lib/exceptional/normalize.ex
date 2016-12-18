defmodule Exceptional.Normalize do
  def normalize(thingy) when is_exception?(thingy), do: thingy

  def normalize({:error, message}), do: Exception.normalize(:error, message)
end

defmodule Exceptional do
  defmacro __using__(opts) do
    use Exceptional.{Control, Raise, TaggedStatus}

    opts
    |> List.wrap
    |> Enum.each fn opt ->
      module = opt |> to_string |> Macro.camelize
      use Module.concat(__MODULE__, module)
    end
  end
end

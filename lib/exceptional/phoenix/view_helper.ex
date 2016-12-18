defmodule Exceptional.Phoenix.ViewHelper do


  @doc ~S"""
  """
  @spec defrender(:error, for: non_neg_integer | String.t, do: String.t) :: String.t | map
  defmacro defrender(:error, for: http_code, do: base_message) do
    status = to_string(http_code)

    quote do
      def render(unquote(status) <> ".html", error_info) do
        case error_info do
          %{conn: %{assigns: %{reason: %{message: detail}}}} ->
            "#{unquote(base_message)}: #{detail}"

          _ -> unquote(base_message)
        end
      end

      def render(unquote(status) <> ".json", error_info) do
        case error_info do
          %{conn: %{assigns: a = %{reason: %{message: detail}}}} ->
            %{error: unquote(base_message), reason: detail}

          _ -> %{error: unquote(base_message)}
        end
      end
    end
  end
end

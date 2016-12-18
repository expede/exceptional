defmodule Exceptional.Phoenix.ViewHelper do
  @moduledoc ~S"""
  Helpers for working with [Phoenix](http://www.phoenixframework.org) views
  """

  @formats ~w(html json)a

  @doc ~S"""
  Generate simple views for Elixir exceptions
  """
  @spec defrender(
    :error,
    for: non_neg_integer | String.t,
    do: String.t
  ) :: String.t | map
  defmacro defrender(:error, for: http_code, do: base_message) do
    render("error", for: http_code, only: @formats, do: base_message)
  end

  defmacro defrender(:error, for: http_code, except: except, do: base_message) do
    only = Enum.reject(@formats, fn format -> Enum.member?(except, format) end)
    render("error", for: http_code, only: only, do: base_message)
  end

  defmacro defrender(:error, for: http_code, only: formats, do: base_message) do
    render("error", for: http_code, only: formats, do: base_message)
  end

  def render("error", for: http_code, only: formats, do: base_message) do
    Enum.map(formats, fn format ->
      render("error", for: http_code, format: format, do: base_message)
    end)
  end

  def render("error", for: http_code, format: format, do: base_message) do
    template = "#{http_code}.#{format}"

    quote do
      def render(unquote(template), error_info) do
        render("#{unquote(format)}", unquote(base_message), error_info)
      end
    end
  end

  def render("html", base_message, error_info) do
    case error_info do
      %{conn: %{assigns: %{reason: %{message: detail}}}} ->
        "#{base_message}: #{detail}"

      _ -> base_message
    end
  end

  def render("json", base_message, error_info) do
    case error_info do
      %{conn: %{assigns: %{reason: %{message: detail}}}} ->
        %{error: base_message, reason: detail}

      _ -> %{error: base_message}
    end
  end
end

defmodule Exceptional.Phoenix.ViewHelper do
  @moduledoc ~S"""
  Helpers for working with [Phoenix](http://www.phoenixframework.org) views
  """

  @formats ~w(html json)a

  @type branch :: {atom, [any], [any]}
  @type ast    :: branch | [branch]

  @type full     :: %{error: String.t, reason: String.t}
  @type simple   :: %{error: String.t}
  @type response :: simple | full

  @doc ~S"""
  Generate simple views for Elixir exceptions

  ## Examples

      defrender :error, for: 404, do: "Sorry, we can't find that resource"
      # ...
      %{error: "Sorry, we can't find that resource", reason: "Photo deleted"}

  """
  @spec defrender(
    :error,
    for: non_neg_integer | String.t,
    do: String.t
  ) :: ast
  defmacro defrender(:error, for: http_code, do: base_message) do
    render(:error, for: http_code, only: @formats, do: base_message)
  end

  @doc ~S"""
  Same as `defrender/2`, but with a format blacklist (ex. `except: [:json]`)
  """
  @spec defrender(:error, for: non_neg_integer, except: [atom], do: String.t)
    :: ast
  defmacro defrender(:error, for: http_code, except: except, do: base_message) do
    only = Enum.reject(@formats, fn format -> Enum.member?(except, format) end)
    render(:errors, for: http_code, only: only, do: base_message)
  end

  @doc ~S"""
  Same as `defrender/2`, but with a format whitelist (ex. `only: [:json]`)
  """
  @spec defrender(:error, for: non_neg_integer, only: [atom], do: String.t)
    :: ast
  defmacro defrender(:error, for: http_code, only: formats, do: base_message) do
    render(:errors, for: http_code, only: formats, do: base_message)
  end

  @doc ~S"""
  Generate several render error functions from a whitelist (`only`)

  ## Examples

      iex> render(:errors, for: 404, only: [:json], do: "Oh no!")
      [
        {
          :def,
          [context: Exceptional.Phoenix.ViewHelper, import: Kernel],
          [
            {
              :render,
              [context: Exceptional.Phoenix.ViewHelper],
              [
                "404.json",
                {:error_info, [], Exceptional.Phoenix.ViewHelper}
              ]
            },
            [do: {
              :render, [], [
                {
                  :<<>>, [], [
                    {
                      :::,
                      [],
                      [
                        {
                          {:., [], [Kernel, :to_string]},
                          [],
                          [:json]
                        },
                        {:binary, [], Exceptional.Phoenix.ViewHelper}
                      ]
                    }
                  ]
                },
                "Oh no!",
                {:error_info, [], Exceptional.Phoenix.ViewHelper}
              ]
            }]
          ]
        }
      ]

  """
  @spec render(:errors, for: non_neg_integer, only: [atom], do: String.t)
    :: response
  def render(:errors, for: http_code, only: formats, do: base_message) do
    Enum.map(formats, fn format ->
      render(:error, for: http_code, format: format, do: base_message)
    end)
  end

  @doc ~S"""
  Generate a single error hander

  ## Examples

      iex> render(:error, for: 404, format: :json, do: "Oh no!")
      {
        :def,
        [context: Exceptional.Phoenix.ViewHelper, import: Kernel],
        [
          {
            :render,
            [context: Exceptional.Phoenix.ViewHelper],
            [
              "404.json",
              {:error_info, [], Exceptional.Phoenix.ViewHelper}
            ]
          },
          [do: {
            :render, [], [
              {
                :<<>>, [], [
                  {
                    :::,
                    [],
                    [
                      {
                        {:., [], [Kernel, :to_string]},
                        [],
                        [:json]
                      },
                      {:binary, [], Exceptional.Phoenix.ViewHelper}
                    ]
                  }
                ]
              },
              "Oh no!",
              {:error_info, [], Exceptional.Phoenix.ViewHelper}
            ]
          }]
        ]
      }


  """
  @spec render(String.t, for: non_neg_integer, format: atom, do: String.t)
    :: response
  def render(:error, for: http_code, format: format, do: base_message) do
    template = "#{http_code}.#{format}"

    quote do
      def render(unquote(template), error_info) do
        render("#{unquote(format)}", unquote(base_message), error_info)
      end
    end
  end

  @doc ~S"""
  Concrete render of an error in a particular format

  ## Examples

      iex> render(:json, "I'm sorry, I can't do that Dave", %{})
      %{error: "I'm sorry, I can't do that Dave"}

  """
  @spec render(:html | :json, String.t, map) :: response
  def render(:html, base_message, error_info) do
    case error_info do
      %{conn: %{assigns: %{reason: %{message: detail}}}} ->
        "#{base_message}: #{detail}"

      _ -> base_message
    end
  end

  def render(:json, base_message, error_info) do
    case error_info do
      %{conn: %{assigns: %{reason: %{message: detail}}}} ->
        %{error: base_message, reason: detail}

      _ -> %{error: base_message}
    end
  end
end

# Exceptional: Helpers for Elixir exceptions
![](https://github.com/expede/exceptional/raw/master/branding/logo_with_text.png)

## Table of Contents
- [Installation](#installation)
- [Prior Art](#prior-art)
  - [Tagged Status](#tagged-status)
  - [Optimistic Flow](#optimistic-flow)
- [Exceptional](#exceptional)
  - [Examples](#examples)
    - [Escape Hatch](#escape-hatch)
    - [Back to Tagged Status](#back-to-tagged-status)
    - [Finally Raise](#finally-raise)
    - [Manually Branch](#manually-branch)

## Installation

Add `exceptional` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:exceptional, "~> 1.0"}]
end
```

## Prior Art
### Tagged Status
The tagged status pattern (`{:ok, _}`, `{:error, _}`, etc)has been the
bread and butter of Erlang since the beginning. While this makes it very easy to
track the meaning of an expression, two things can happen:

1. The tag becomes out of sync
  - ex. `{:ok, "and yet not ok"}`

2. Pattern matching becomes challenging when different lengths exist
  - ex. `{:error, "oopsie"}`, `{:error, "oopsie", %{original: :data, for: "handling"}}`

### Optimistic Flow
The other alternative is to be optimistic returns, generally seen with bang patterns.
Ex. `doc = File.read! path` instead of `{:ok, doc} = File.read path"`. This is
more convenient, but will `raise`, robbing the caller of control without `try/catch`.

### Error Monad
Currently a very undersused pattern in the Erlang/Elixir ecosystem, this is probably
"the right way" to do general error handling (or at last the most theoretically pure one).
Essentially, wrap your computation in an [ADT struct](https://hex.pm/packages/algae),
paired with a [binding function](https://hexdocs.pm/witchcraft/Witchcraft.Monad.Operator.html#%3E%3E%3E/2)
(super-powered `|>`), that escapes the pipe flow if it encounters an `Exception`.

The downside is of course that people are generally afraid of introducing monads into
their Elixir code, as understanding it requires some theoretical understanding.

## Exceptional
`Exceptional` takes a hybrid approach. The aim is to behave similar to an error monad,
but in a more Elixir-y way. This is less powerful than the monad solution, but simpler to
understand fully, and cleaner than optimistic flow, and arguably more convenient than the
classic tagged status.

## Examples

### [Escape Hatch](https://hexdocs.pm/exceptional/Exceptional.Value.html)

```elixir
[1,2,3] ~> Enum.sum
#=> 6

Enum.OutOfBoundsError.exception("exception") ~> Enum.sum
#=> %Enum.OutOfBoundsError{message: "exception"}

[1,2,3]
|> hypothetical_returns_exception
~> fn would_be_list ->
  would_be_list
  |> Enum.map(fn x -> x + 1 end)
  |> Enum.sum
end.()
#=> %Enum.OutOfBoundsError{message: "exception"}

0..10
|> Enum.take(3)
~> fn list ->
  list
  |> Enum.map(fn x -> x + 1 end)
  |> Enum.sum
end.()
#=> 6
```

### [Back to Tagged Status](https://hexdocs.pm/exceptional/Exceptional.TaggedStatus.html)

```elixir
[1,2,3]
|> hypothetical_returns_exception
~> fn would_be_list ->
would_be_list
|> Enum.map(fn x -> x + 1 end)
end.()
#=>  {:error, "exception"}

0..10
|> Enum.take(3)
~> fn list ->
list
|> Enum.map(fn x -> x + 1 end)
|< Enum.sum
end.()
|> to_tagged_status
#=> {:ok, 6}
```

### [Finally Raise](https://hexdocs.pm/exceptional/Exceptional.Raise.html)

```elixir
[1,2,3] >>> Enum.sum
#=> 2

%ArgumentError{message: "raise me"} >>> Enum.sum
#=> ** (ArgumentError) raise me
```

### [`Manually Branch`](https://hexdocs.pm/exceptional/Exceptional.Control.html)

```elixir
Exceptional.Control.branch 1,
  value_do: fn v -> v + 1 end.(),
  exception_do: fn %{message: msg} -> msg end.()
#=> 2

ArgumentError.exception("error message"),
|> Exceptional.Control.branch(value_do: fn v -> v end.(), exception_do: fn %{message: msg} -> msg end.())
#=> "error message"

if_exception 1, do: fn %{message: msg} -> msg end.(), else: fn v -> v + 1 end.(),
#=> 2

ArgumentError.exception("error message"),
|> if_exception do
  fn %{message: msg} -> msg end.())
else
  fn v -> v end.()
end
#=> "error message"
```

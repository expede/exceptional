# Exceptional: Helpers for Elixir exceptions
![](https://github.com/expede/exceptional/raw/master/branding/logo_with_text.png)

[![Build Status](https://travis-ci.org/expede/exceptional.svg?branch=master)](https://travis-ci.org/expede/exceptional) [![Inline docs](http://inch-ci.org/github/expede/exceptional.svg?branch=master)](http://inch-ci.org/github/expede/exceptional) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/expede/exceptional.svg)](https://beta.hexfaktor.org/github/expede/exceptional) [![hex.pm version](https://img.shields.io/hexpm/v/exceptional.svg?style=flat)](https://hex.pm/packages/exceptional) [![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/exceptional/) [![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/expede/exceptional/blob/master/LICENSE)

## Table of Contents
- [Installation](#installation)
- [About](#about)
- [Prior Art](#prior-art)
  - [Tagged Status](#tagged-status)
  - [Optimistic Flow](#optimistic-flow)
- [Exceptional](#exceptional)
  - [Examples](#examples)
    - [Make Safe](#make-safe)
    - [Escape Hatch](#escape-hatch)
    - [Normalize Errors](#normalize-errors)
    - [Back to Tagged Status](#back-to-tagged-status)
    - [Finally Raise](#finally-raise)
    - [Manually Branch](#manually-branch)
- [Related Packages](#related-packages)

## Installation

Add `exceptional` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:exceptional, "~> 2.0"}]
end
```

## About
Exceptional is an Elixir library providing helpers for working with exceptions.
It aims to make working with plain old (unwrapped) Elixir values more convenient,
and to give full control back to calling functions.

See the [Medium article](https://medium.com/the-monad-nomad/exceptional-freedom-from-error-s-eaabfae25d72#.zgbne4gja) for more

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

This is a classic inversion of control, and allows for very flexible patterns.
For example, using [`>>>`](#finally-raise) (ie: `raise` if exception, otherwise continue) sidesteps
the need for separate bang functions.

Just like the classic FP wisdom: if it doubt, pass it back to the caller to handle.

## Examples

### [Make Safe](https://hexdocs.pm/exceptional/Exceptional.Safe.html)

A simple way to declaw a function that normally `raise`s. (Does not change the behaviour of functions that don't `raise`).

```elixir
toothless_fetch = safe(&Enum.fetch!/2)
[1,2,3] |> toothless_fetch.(1)
#=> 2

toothless = safe(&Enum.fetch!/2)
[1,2,3] |> toothless.(999)
#=> %Enum.OutOfBoundsError{message: "out of bounds error"}

safe(&Enum.fetch!/2).([1,2,3], 999)
#=> %Enum.OutOfBoundsError{message: "out of bounds error"}
```

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

### [Normalize Errors](https://hexdocs.pm/exceptional/Exceptional.Normalize.html)

Elixir and Erlang interoperate, but represent errors differently. `normalize` normalizes values into exceptions or plain values (no `{:error, _}` tuples).
This can be seen as the opposite of the functions that convert back to [tagged status](#back-to-tagged-status).
Some error types may not be detected; but you may pass a custom converter (see examples below).

```elixir
normalize(42)
#=> 42

normalize(%Enum.OutOfBoundsError{message: "out of bounds error"})
#=> %Enum.OutOfBoundsError{message: "out of bounds error"}

normalize(:error)
#=> %ErlangError{original: nil}

normalize(:error)
#=> %ErlangError{original: nil}

normalize({:error, "boom"})
#=> %ErlangError{original: "boom"}

normalize({:error, {1, 2, 3}})
#=> %ErlangError{original: {1, 2, 3}}

normalize({:error, "boom with stacktrace", ["trace"]})
#=> %ErlangError{original: "boom with stacktrace"}

normalize({:good, "tuple", ["value"]})
#=> {:good, "tuple", ["value"]}

{:oh_no, {"something bad happened", %{bad: :thing}}}
|> normalize(fn
  {:oh_no, {message, _}} -> %File.Error{reason: message}) # This case
  {:bang, message        -> %File.CopyError{reason: message})
  otherwise              -> otherwise
end)
#=> %File.Error{message: msg}

{:oh_yes, {1, 2, 3}}
|> normalize(fn
  {:oh_no, {message, _}} -> %File.Error{reason: message})
  {:bang, message        -> %File.CopyError{reason: message})
  otherwise              -> otherwise # This case
end)
#=> {:oh_yes, {1, 2, 3}}
```

### [Back to Tagged Status](https://hexdocs.pm/exceptional/Exceptional.TaggedStatus.html)

```elixir
[1,2,3]
|> hypothetical_returns_exception
~> fn list ->
  list
  |> Enum.map(fn x -> x + 1 end)
  |> Enum.sum
end.()
#=>  {:error, "exception"}

0..10
|> Enum.take(3)
~> fn list ->
  list
  |> Enum.map(fn x -> x + 1 end)
  |> Enum.sum
end.()
|> to_tagged_status
#=> {:ok, 6}


0..10
|> hypothetical_returns_exception
~> fn list ->
  list
  |> Enum.map(fn x -> x + 1 end)
  |> Enum.sum
end.()
|> ok
#=>  {:error, "exception"}


maybe_sum =
  0..10
  |> hypothetical_returns_exception
  ~> fn list ->
    list
    |> Enum.map(fn x -> x + 1 end)
    |> Enum.sum
  end.()

~~~maybe_sum
#=>  {:error, "exception"}

```

### [Finally Raise](https://hexdocs.pm/exceptional/Exceptional.Raise.html)

Note that this does away with the need for separate `foo` and `foo!` functions,
thanks to the inversion of control.

```elixir
[1,2,3] >>> Enum.sum
#=> 6

%ArgumentError{message: "raise me"} >>> Enum.sum
#=> ** (ArgumentError) raise me

ensure!([1, 2, 3])
#=> [1, 2, 3]

ensure!(%ArgumentError{message: "raise me"})
#=> ** (ArgumentError) raise me

defmodule Foo do
  use Exceptional

  def! foo(a), do: a
end

Foo.foo([1, 2, 3])
#=> [1, 2, 3]

Foo.foo(%ArgumentError{message: "raise me"})
#=> %ArgumentError{message: "raise me"}

Foo.foo!([1, 2, 3])
#=> [1, 2, 3]

Foo.foo!(%ArgumentError{message: "raise me"})
#=> ** (ArgumentError) raise me

```

### [Manually Branch](https://hexdocs.pm/exceptional/Exceptional.Control.html)

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

ArgumentError.exception("error message")
|> if_exception do
  fn %{message: msg} -> msg end.())
else
  fn v -> v end.()
end
#=> "error message"
```

## Related Packages

- [Phoenix/Exceptional](https://hex.pm/packages/phoenix_exceptional)

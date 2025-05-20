defmodule KurpoBot.MessageUtil do
  @moduledoc """
  Utilities for working with Nostrum messages.
  """

  alias Nostrum.Struct.Message

  @doc """
  Returns true if the message contains the given text.

  ## Examples

      iex> contains?(%Nostrum.Struct.Message{content: "Hello world"}, "hello")
      true

      iex> contains?(%Nostrum.Struct.Message{content: "Hello world"}, "goodbye")
      false
  """
  @spec contains?(Message.t(), String.t()) :: boolean()
  def contains?(%Message{content: content}, text) do
    content
    |> String.downcase()
    |> String.contains?(text)
  end

  @doc """
  Returns true if the message mentions the given user(s).

  ## Examples

      iex> mentions?(%Nostrum.Struct.Message{mentions: [%Nostrum.Struct.User{id: 123}]}, 123)
      true

      iex> mentions?(%Nostrum.Struct.Message{mentions: [%Nostrum.Struct.User{id: 123}]}, [123, 222])
      true

      iex> mentions?(%Nostrum.Struct.Message{mentions: [%Nostrum.Struct.User{id: 123}]}, 456)
      false
  """
  @spec mentions?(Message.t(), integer() | [integer()]) :: boolean()
  def mentions?(%Message{mentions: mentions}, user_id) when is_integer(user_id) do
    Enum.any?(mentions, fn m -> m.id == user_id end)
  end

  def mentions?(%Message{mentions: mentions}, user_ids) when is_list(user_ids) do
    Enum.any?(mentions, fn m -> m.id in user_ids end)
  end

  @doc """
  Returns true if the message asks for a ping.

  ## Examples

      iex> ping?(%Nostrum.Struct.Message{content: "ping"})
      true

      iex> ping?(%Nostrum.Struct.Message{content: "something else"})
      false
  """
  @spec ping?(Message.t()) :: boolean()
  def ping?(%Message{} = msg) do
    contains?(msg, "ping")
  end

  @doc """
  Returns true if the message is a reply to the given user(s).

  ## Examples

      iex> reply?(%Nostrum.Struct.Message{referenced_message: %Nostrum.Struct.Message{author: %Nostrum.Struct.User{id: 123}}}, 123)
      true

      iex> reply?(%Nostrum.Struct.Message{referenced_message: %Nostrum.Struct.Message{author: %Nostrum.Struct.User{id: 123}}}, [123, 222])
      true

      iex> reply?(%Nostrum.Struct.Message{referenced_message: %Nostrum.Struct.Message{author: %Nostrum.Struct.User{id: 123}}}, 456)
      false
  """
  @spec reply?(Message.t(), integer() | [integer()]) :: boolean()
  def reply?(%Message{referenced_message: nil}, _user_ids) do
    false
  end

  def reply?(%Message{referenced_message: m}, user_id) when is_integer(user_id) do
    m.author.id == user_id
  end

  def reply?(%Message{referenced_message: m}, user_ids) when is_list(user_ids) do
    m.author.id in user_ids
  end

  @doc """
  Returns true if the message is a storytime message.

  ## Examples

      iex> storytime?(%Nostrum.Struct.Message{content: "storytime"})
      true

      iex> storytime?(%Nostrum.Struct.Message{content: "something else"})
      false
  """
  @spec storytime?(Message.t()) :: boolean()
  def storytime?(%Message{} = msg) do
    contains?(msg, "storytime")
  end
end

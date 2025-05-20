defmodule KurpoBot.MainConsumerTest do
  use KurpoBot.DataCase, async: true
  alias KurpoBot.Repo

  describe "handle_event/1 :MESSAGE_CREATE" do
    test "unknown !commands are ignored" do
      message = nostrum_message(content: "!unknown")
      event = {:MESSAGE_CREATE, message, %{}}
      assert KurpoBot.MainConsumer.handle_event(event) == :ignore
    end

    test "saves messages for configured user" do
      content = "example message"
      message = nostrum_message(content: content, author: %{id: 1111})
      event = {:MESSAGE_CREATE, message, %{}}
      KurpoBot.MainConsumer.handle_event(event)

      m = Repo.get_by(KurpoBot.Repo.Message, content: content)
      assert m.user_id == 1111
    end

    test "ignores messages from other users" do
      content = "example message"
      message = nostrum_message(content: content, author: %{id: 9999})
      event = {:MESSAGE_CREATE, message, %{}}
      KurpoBot.MainConsumer.handle_event(event)

      refute Repo.get_by(KurpoBot.Repo.Message, content: content)
    end
  end

  describe "handle_event/1 catch-all" do
    test "doesn't crash on unknown events" do
      assert KurpoBot.MainConsumer.handle_event({:UNKNOWN_EVENT, %{}, %{}}) == :noop
    end
  end

  def nostrum_message(attrs \\ %{}) do
    struct(
      %Nostrum.Struct.Message{
        author: %Nostrum.Struct.User{id: 1},
        channel_id: 1,
        content: "",
        guild_id: 1,
        id: 1,
        mentions: []
      },
      attrs
    )
  end
end

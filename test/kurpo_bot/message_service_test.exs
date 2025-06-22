defmodule KurpoBot.MessageServiceTest do
  use KurpoBot.DataCase

  test "get_random/1 gets a random message" do
    user_id = 1234
    m1 = insert!(:message, user_id: user_id)
    m2 = insert!(:message, user_id: user_id)
    _m3 = insert!(:message, user_id: 9999)

    message = KurpoBot.MessageService.get_random([user_id])
    assert message.id == m1.id || message.id == m2.id
  end

  test "get_random_with_ping/1 gets a random message with an @ping" do
    user_id = 1234
    m1 = insert!(:message, user_id: user_id, content: "Example <@!1234>")
    m2 = insert!(:message, user_id: user_id, content: "Another <@!2222>")
    _m3 = insert!(:message, user_id: user_id)
    _m4 = insert!(:message, user_id: 9999)

    message = KurpoBot.MessageService.get_random_with_ping([user_id])
    assert message.id == m1.id || message.id == m2.id
  end

  test "total/1 returns the total messages for given users" do
    user_id = 1234
    _m1 = insert!(:message, user_id: user_id)
    _m2 = insert!(:message, user_id: user_id)
    _m3 = insert!(:message, user_id: 9999)

    assert KurpoBot.MessageService.total([user_id]) == 2
  end
end

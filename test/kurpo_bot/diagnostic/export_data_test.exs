defmodule KurpoBot.Diagnostic.ExportDataTest do
  use KurpoBot.DataCase

  alias KurpoBot.Diagnostic.ExportData

  describe "ExportData.run/1" do
    test "exports data to file with default parameters" do
      # Create test data
      channel = insert!(:channel)
      message = insert!(:message)

      result = ExportData.run(%{})

      assert %{success: true, data: %{export_file_path: file_path, export_metadata: metadata}} =
               result

      assert is_binary(file_path)
      assert File.exists?(file_path)

      # Verify metadata
      assert %{
               version: _,
               exported_at: _,
               totals: %{
                 channels: 1,
                 messages: 1
               }
             } = metadata

      # Parse the JSON file to verify structure
      json_content = File.read!(file_path)
      parsed = JSON.decode!(json_content)

      assert %{
               "version" => _,
               "exported_at" => _,
               "totals" => %{
                 "channels" => 1,
                 "messages" => 1
               },
               "data" => %{
                 "channels" => [channel_data],
                 "messages" => [message_data]
               }
             } = parsed

      assert channel_data["channel_id"] == channel.channel_id
      assert message_data["message_id"] == message.message_id

      # Clean up
      File.rm!(file_path)
    end

    test "exports empty data when no records exist" do
      result = ExportData.run(%{})

      assert %{success: true, data: %{export_file_path: file_path, export_metadata: metadata}} =
               result

      assert File.exists?(file_path)

      json_content = File.read!(file_path)
      parsed = JSON.decode!(json_content)

      assert %{
               "version" => _,
               "exported_at" => _,
               "totals" => %{
                 "channels" => 0,
                 "messages" => 0
               },
               "data" => %{
                 "channels" => [],
                 "messages" => []
               }
             } = parsed

      assert metadata.totals.channels == 0
      assert metadata.totals.messages == 0

      # Clean up
      File.rm!(file_path)
    end

    test "exports multiple records correctly" do
      # Create multiple test records
      for _ <- 1..3, do: insert!(:channel)
      for _ <- 1..5, do: insert!(:message)

      result = ExportData.run(%{})

      assert %{success: true, data: %{export_file_path: file_path, export_metadata: metadata}} =
               result

      json_content = File.read!(file_path)
      parsed = JSON.decode!(json_content)

      assert %{
               "totals" => %{
                 "channels" => 3,
                 "messages" => 5
               }
             } = parsed

      assert length(parsed["data"]["channels"]) == 3
      assert length(parsed["data"]["messages"]) == 5

      assert metadata.totals.channels == 3
      assert metadata.totals.messages == 5

      # Clean up
      File.rm!(file_path)
    end
  end

  describe "file structure" do
    test "creates export directory if it doesn't exist" do
      # This test ensures the export directory is created
      result = ExportData.run(%{})
      assert %{success: true, data: %{export_file_path: file_path}} = result

      export_dir = Path.dirname(file_path)
      assert File.exists?(export_dir)
      assert File.dir?(export_dir)

      # Clean up
      File.rm!(file_path)
    end
  end

  describe "serialize_channels/1" do
    test "serializes channel data correctly" do
      channel = insert!(:channel, is_ignored: true)

      result = ExportData.run(%{})
      assert %{success: true, data: %{export_file_path: file_path}} = result

      json_content = File.read!(file_path)
      parsed = JSON.decode!(json_content)

      [channel_data] = parsed["data"]["channels"]

      assert channel_data["id"] == channel.id
      assert channel_data["channel_id"] == channel.channel_id
      assert channel_data["guild_id"] == channel.guild_id
      assert channel_data["is_ignored"] == true

      # Clean up
      File.rm!(file_path)
    end
  end

  describe "serialize_messages/1" do
    test "serializes message data correctly" do
      message = insert!(:message, content: "Test message", user_id: 12_345)

      result = ExportData.run(%{})
      assert %{success: true, data: %{export_file_path: file_path}} = result

      json_content = File.read!(file_path)
      parsed = JSON.decode!(json_content)

      [message_data] = parsed["data"]["messages"]

      assert message_data["id"] == message.id
      assert message_data["channel_id"] == message.channel_id
      assert message_data["content"] == "Test message"
      assert message_data["guild_id"] == message.guild_id
      assert message_data["message_id"] == message.message_id
      assert message_data["user_id"] == 12_345

      # Clean up
      File.rm!(file_path)
    end
  end
end

defmodule KurpoBot.Diagnostic.ImportDataTest do
  use KurpoBot.DataCase

  alias KurpoBot.Diagnostic.{ExportData, ImportData}

  describe "ImportData.run/1" do
    test "imports valid JSON data from file" do
      # First create and export some data
      channel = insert!(:channel)
      message = insert!(:message)

      export_result = ExportData.run(%{})
      assert %{success: true, data: %{export_file_path: file_path}} = export_result

      # Clear the data
      KurpoBot.Repo.delete_all(KurpoBot.Repo.Message)
      KurpoBot.Repo.delete_all(KurpoBot.Repo.Channel)

      # Now import it back
      result = ImportData.run(%{file_path: file_path})

      assert %{success: true, data: %{import_results: results}} = result

      assert %{
               imported_at: _,
               dry_run: false,
               totals: %{
                 channels: 1,
                 messages: 1
               }
             } = results

      # Verify the data was imported
      assert KurpoBot.Repo.total(KurpoBot.Repo.Channel) == 1
      assert KurpoBot.Repo.total(KurpoBot.Repo.Message) == 1

      imported_channel = KurpoBot.Repo.all(KurpoBot.Repo.Channel) |> List.first()
      imported_message = KurpoBot.Repo.all(KurpoBot.Repo.Message) |> List.first()

      assert imported_channel.channel_id == channel.channel_id
      assert imported_message.message_id == message.message_id

      # Clean up
      File.rm!(file_path)
    end

    test "fails for non-existent file" do
      result = ImportData.run(%{file_path: "/non/existent/file.json"})

      assert %{success: false, errors: %{file_not_found: error_message}} = result
      assert error_message =~ "File does not exist"
    end

    test "fails for invalid JSON structure" do
      # Create a temporary file with invalid JSON structure
      temp_path = Path.join(System.tmp_dir!(), "invalid_import.json")

      invalid_data = %{invalid: "structure"}
      File.write!(temp_path, JSON.encode!(invalid_data))

      result = ImportData.run(%{file_path: temp_path})

      assert %{success: false, errors: %{data_structure: error_message}} = result
      assert error_message =~ "Invalid JSON structure"

      # Clean up
      File.rm!(temp_path)
    end

    test "validates only when dry_run is true" do
      # Create and export some data
      insert!(:channel)
      insert!(:message)

      export_result = ExportData.run(%{})
      assert %{success: true, data: %{export_file_path: file_path}} = export_result

      # Clear the data
      KurpoBot.Repo.delete_all(KurpoBot.Repo.Message)
      KurpoBot.Repo.delete_all(KurpoBot.Repo.Channel)

      # Run dry run
      result = ImportData.run(%{file_path: file_path, dry_run: true})

      assert %{success: true, data: %{import_results: results}} = result
      assert results.dry_run == true

      # Verify no data was actually imported
      assert KurpoBot.Repo.total(KurpoBot.Repo.Channel) == 0
      assert KurpoBot.Repo.total(KurpoBot.Repo.Message) == 0

      # Clean up
      File.rm!(file_path)
    end

    test "always clears existing data when importing" do
      # Create some initial data
      initial_channel = insert!(:channel)
      initial_message = insert!(:message)

      # Create export data with different records
      new_channel = build(:channel, channel_id: 999_999, guild_id: 888_888)
      new_message = build(:message, message_id: 777_777, content: "New message")

      export_data = %{
        version: "0.6.6",
        exported_at: DateTime.utc_now(),
        totals: %{channels: 1, messages: 1},
        data: %{
          channels: [
            %{
              id: nil,
              channel_id: new_channel.channel_id,
              guild_id: new_channel.guild_id,
              is_ignored: false
            }
          ],
          messages: [
            %{
              id: nil,
              channel_id: new_message.channel_id,
              content: new_message.content,
              guild_id: new_message.guild_id,
              message_id: new_message.message_id,
              user_id: new_message.user_id
            }
          ]
        }
      }

      # Write to a temporary file
      temp_path = Path.join(System.tmp_dir!(), "clear_existing_import.json")
      File.write!(temp_path, JSON.encode!(export_data))

      result = ImportData.run(%{file_path: temp_path})

      assert %{success: true, data: %{import_results: _results}} = result

      # Verify old data was cleared and new data was imported
      assert KurpoBot.Repo.total(KurpoBot.Repo.Channel) == 1
      assert KurpoBot.Repo.total(KurpoBot.Repo.Message) == 1

      imported_channel = KurpoBot.Repo.all(KurpoBot.Repo.Channel) |> List.first()
      imported_message = KurpoBot.Repo.all(KurpoBot.Repo.Message) |> List.first()

      assert imported_channel.channel_id == new_channel.channel_id
      assert imported_message.message_id == new_message.message_id

      # Verify old data is gone
      refute KurpoBot.Repo.get_by(KurpoBot.Repo.Channel, channel_id: initial_channel.channel_id)
      refute KurpoBot.Repo.get_by(KurpoBot.Repo.Message, message_id: initial_message.message_id)

      # Clean up
      File.rm!(temp_path)
    end

    test "raises exception on invalid schema fields" do
      # Create some initial data that should remain if import fails
      initial_channel = insert!(:channel)
      initial_message = insert!(:message)

      # Create invalid export data that will cause import to fail
      # Use a non-existent column to trigger Ecto schema error
      invalid_export_data = %{
        version: "0.6.6",
        exported_at: DateTime.utc_now(),
        totals: %{channels: 1, messages: 1},
        data: %{
          channels: [
            %{
              channel_id: 123_456,
              guild_id: 123_456,
              is_ignored: false,
              # This column doesn't exist and will cause Ecto schema error
              non_existent_column: "invalid"
            }
          ],
          messages: [
            %{
              channel_id: 123,
              content: "test",
              message_id: 456,
              user_id: 789
            }
          ]
        }
      }

      # Write to a temporary file
      temp_path = Path.join(System.tmp_dir!(), "invalid_import.json")
      File.write!(temp_path, JSON.encode!(invalid_export_data))

      # Assert that the ArgumentError is raised for unknown field
      assert_raise ArgumentError, ~r/unknown field `:non_existent_column`/, fn ->
        ImportData.run(%{file_path: temp_path})
      end

      # Verify original data is still there (transaction rolled back)
      assert KurpoBot.Repo.total(KurpoBot.Repo.Channel) == 1
      assert KurpoBot.Repo.total(KurpoBot.Repo.Message) == 1

      found_channel =
        KurpoBot.Repo.get_by(KurpoBot.Repo.Channel, channel_id: initial_channel.channel_id)

      found_message =
        KurpoBot.Repo.get_by(KurpoBot.Repo.Message, message_id: initial_message.message_id)

      assert found_channel
      assert found_message

      # Clean up
      File.rm!(temp_path)
    end

    test "fails for mismatched totals" do
      # Create a file with mismatched totals
      temp_path = Path.join(System.tmp_dir!(), "mismatched_export.json")

      invalid_data = %{
        version: "0.6.6",
        exported_at: DateTime.utc_now(),
        totals: %{channels: 2, messages: 3},
        data: %{
          channels: [%{channel_id: 123, guild_id: 456}],
          messages: [%{channel_id: 123, content: "test", message_id: 789, user_id: 101_112}]
        }
      }

      File.write!(temp_path, JSON.encode!(invalid_data))

      result = ImportData.run(%{file_path: temp_path})

      assert %{success: false, errors: %{data_structure: error_message}} = result
      assert error_message =~ "Totals mismatch"

      # Clean up
      File.rm!(temp_path)
    end
  end
end

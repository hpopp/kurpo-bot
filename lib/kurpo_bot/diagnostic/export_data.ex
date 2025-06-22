defmodule KurpoBot.Diagnostic.ExportData do
  @moduledoc """
  Command to export all repository data (channels and messages) to JSON format.
  Streams data to a file to handle large datasets efficiently without loading into memory.
  """

  import Commandex

  alias KurpoBot.Repo
  alias KurpoBot.Repo.{Channel, Message}

  command do
    data :export_file_path
    data :export_metadata

    pipeline :generate_filename
    pipeline :stream_to_file
  end

  @doc """
  Generates a filename for the export file.
  """
  @spec generate_filename(t(), map(), map()) :: t()
  def generate_filename(command, _params, _data) do
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601(:basic)
    filename = "kurpobot_export_#{timestamp}.json"
    file_path = Path.join(export_dir(), filename)
    put_data(command, :export_file_path, file_path)
  end

  @doc """
  Streams the export data to a JSON file using Ecto streaming.
  """
  @spec stream_to_file(t(), map(), map()) :: t()
  def stream_to_file(command, _params, %{export_file_path: file_path}) do
    # Ensure export directory exists
    File.mkdir_p!(export_dir())

    # Get totals for metadata
    channels_count = Repo.total(Channel)
    messages_count = Repo.total(Message)

    metadata = %{
      version: KurpoBot.version(),
      exported_at: DateTime.utc_now(),
      totals: %{
        channels: channels_count,
        messages: messages_count
      }
    }

    try do
      File.open!(file_path, [:write], fn file ->
        # Write opening structure
        IO.write(file, "{")
        IO.write(file, "\"version\":#{JSON.encode!(metadata.version)},")
        IO.write(file, "\"exported_at\":#{JSON.encode!(metadata.exported_at)},")
        IO.write(file, "\"totals\":{")
        IO.write(file, "\"channels\":#{metadata.totals.channels},")
        IO.write(file, "\"messages\":#{metadata.totals.messages}")
        IO.write(file, "},")
        IO.write(file, "\"data\":{")

        # Stream channels
        IO.write(file, "\"channels\":[")
        stream_model_to_file(file, Channel)
        IO.write(file, "],")

        # Stream messages
        IO.write(file, "\"messages\":[")
        stream_model_to_file(file, Message)
        IO.write(file, "]")

        # Close structure
        IO.write(file, "}}")
      end)

      command
      |> put_data(:export_metadata, metadata)
    rescue
      error ->
        # Clean up the file if it was created
        File.rm(file_path)

        command
        |> put_error(:file_export, "Failed to write export file: #{inspect(error)}")
        |> halt()
    end
  end

  # Private helper functions

  @spec export_dir :: String.t()
  defp export_dir do
    priv_dir = :code.priv_dir(:kurpo_bot)
    Path.join(priv_dir, "exports")
  end

  @spec stream_model_to_file(IO.device(), module()) :: :ok
  defp stream_model_to_file(file, model) do
    Repo.transaction(fn ->
      model
      |> Repo.stream(max_rows: 1000)
      |> Stream.with_index()
      |> Enum.each(&write_model_json(file, &1))
    end)

    :ok
  end

  @spec write_model_json(IO.device(), {struct(), non_neg_integer()}) :: :ok
  defp write_model_json(file, {record, index}) do
    record_json = JSON.encode!(record)

    if index > 0 do
      IO.write(file, ",")
    end

    IO.write(file, record_json)
  end
end

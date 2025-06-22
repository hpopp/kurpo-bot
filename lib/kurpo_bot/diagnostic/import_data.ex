defmodule KurpoBot.Diagnostic.ImportData do
  @moduledoc """
  Command to import repository data (channels and messages) from JSON export file.
  Always clears existing data and imports new data within a transaction.
  """

  import Commandex

  alias KurpoBot.Repo
  alias KurpoBot.Repo.{Channel, Message}

  command do
    param :file_path
    param :dry_run, default: false

    data :parsed_data
    data :channels_data
    data :messages_data
    data :import_results

    pipeline :validate_file_exists
    pipeline :read_and_parse_file
    pipeline :validate_json_structure
    pipeline :parse_import_data
    pipeline :import_data_transaction
    pipeline :build_results
  end

  @doc """
  Validates that the file exists and is readable.
  """
  @spec validate_file_exists(t(), map(), map()) :: t()
  def validate_file_exists(command, %{file_path: file_path}, _data) do
    cond do
      not File.exists?(file_path) ->
        command
        |> put_error(:file_not_found, "File does not exist: #{file_path}")
        |> halt()

      not File.regular?(file_path) ->
        command
        |> put_error(:invalid_file, "Path is not a regular file: #{file_path}")
        |> halt()

      true ->
        command
    end
  end

  @doc """
  Reads and parses the JSON file.
  """
  @spec read_and_parse_file(t(), map(), map()) :: t()
  def read_and_parse_file(command, %{file_path: file_path}, _data) do
    content = File.read!(file_path)
    parsed = JSON.decode!(content)
    put_data(command, :parsed_data, parsed)
  rescue
    error ->
      command
      |> put_error(:file_reading, "Failed to read or parse file: #{inspect(error)}")
      |> halt()
  end

  @doc """
  Validates the basic JSON structure.
  """
  @spec validate_json_structure(t(), map(), map()) :: t()
  def validate_json_structure(command, _params, %{parsed_data: parsed_data}) do
    case parsed_data do
      %{
        "version" => version,
        "exported_at" => _exported_at,
        "totals" => %{"channels" => channels_count, "messages" => messages_count},
        "data" => %{"channels" => channels, "messages" => messages}
      }
      when is_binary(version) and is_integer(channels_count) and is_integer(messages_count) and
             is_list(channels) and is_list(messages) ->
        # Validate that totals match actual data
        if length(channels) == channels_count and length(messages) == messages_count do
          command
        else
          command
          |> put_error(
            :data_structure,
            "Totals mismatch: declared #{channels_count} channels, #{messages_count} messages, but found #{length(channels)} channels, #{length(messages)} messages"
          )
          |> halt()
        end

      _ ->
        command
        |> put_error(
          :data_structure,
          "Invalid JSON structure. Expected version, exported_at, totals, and data fields"
        )
        |> halt()
    end
  end

  @doc """
  Extracts channels and messages data from parsed JSON.
  """
  @spec parse_import_data(t(), map(), map()) :: t()
  def parse_import_data(command, _params, %{parsed_data: parsed_data}) do
    channels = parsed_data["data"]["channels"]
    messages = parsed_data["data"]["messages"]

    command
    |> put_data(:channels_data, channels)
    |> put_data(:messages_data, messages)
  end

  @doc """
  Imports data within a transaction. Clears existing data and imports new data.
  """
  @spec import_data_transaction(t(), map(), map()) :: t()
  def import_data_transaction(command, %{dry_run: true}, _data) do
    # Skip actual import for dry run
    command
  end

  def import_data_transaction(command, _params, data) do
    %{channels_data: channels, messages_data: messages} = data

    case Repo.transaction(fn -> perform_import(channels, messages) end) do
      {:ok, _result} ->
        command

      {:error, reason} ->
        command
        |> put_error(:import_transaction, "Import transaction failed: #{reason}")
        |> halt()
    end
  end

  @doc """
  Builds the import results summary.
  """
  @spec build_results(t(), map(), map()) :: t()
  def build_results(command, params, %{channels_data: channels, messages_data: messages}) do
    results = %{
      imported_at: DateTime.utc_now(),
      dry_run: Map.get(params, :dry_run, false),
      totals: %{
        channels: length(channels),
        messages: length(messages)
      }
    }

    put_data(command, :import_results, results)
  end

  @spec bulk_insert_models(module(), [map()], String.t()) :: :ok
  defp bulk_insert_models(_model_module, [], _model_name), do: :ok

  defp bulk_insert_models(model_module, data_list, model_name) do
    # Prepare data for bulk insert - just atomize keys and remove id
    prepared_data =
      Enum.map(data_list, fn model_attrs ->
        model_attrs
        |> Map.drop(["id"])
        |> atomize_keys()
      end)

    # Bulk insert - let the database handle validation
    case Repo.insert_all(model_module, prepared_data) do
      {count, _} when count == length(prepared_data) -> :ok
      _ -> Repo.rollback("Failed to insert all #{model_name}")
    end
  end

  @spec perform_import([map()], [map()]) :: :ok
  defp perform_import(channels, messages) do
    # Clear existing data
    Repo.delete_all(Message)
    Repo.delete_all(Channel)

    # Bulk insert channels and messages
    bulk_insert_models(Channel, channels, "channels")
    bulk_insert_models(Message, messages, "messages")

    :ok
  end

  @spec atomize_keys(map()) :: map()
  defp atomize_keys(map) when is_map(map) do
    Map.new(map, fn
      {key, value} when is_binary(key) -> {String.to_existing_atom(key), value}
      {key, value} when is_atom(key) -> {key, value}
    end)
  end
end

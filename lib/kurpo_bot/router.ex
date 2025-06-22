defmodule KurpoBot.Router do
  @moduledoc """
  HTTP router for diagnostic export/import endpoints.
  """

  use Plug.Router

  alias KurpoBot.Diagnostic.{ExportData, ImportData}

  plug :match

  plug Plug.Parsers,
    parsers: [:multipart, :json],
    json_decoder: JSON,
    length: 100_000_000

  plug :dispatch

  get "/health" do
    response = JSend.success(%{status: "ok", timestamp: DateTime.utc_now()})
    send_resp(conn, 200, JSON.encode!(response))
  end

  get "/export" do
    case ExportData.run(%{}) do
      %{success: true, data: %{export_file_path: file_path, export_metadata: metadata}} ->
        # Generate a filename for download
        timestamp = DateTime.to_iso8601(metadata.exported_at, :basic)
        filename = "kurpobot_export_#{timestamp}.json"

        conn
        |> put_resp_content_type("application/json")
        |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
        |> send_file(200, file_path)

      %{success: false, errors: errors} ->
        response = JSend.fail(errors)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, JSON.encode!(response))
    end
  end

  post "/import" do
    case get_uploaded_file(conn) do
      {:ok, file_path} ->
        params = %{
          file_path: file_path,
          dry_run: parse_boolean(conn.query_params["dry_run"], false)
        }

        case ImportData.run(params) do
          %{success: true, data: %{import_results: results}} ->
            response = JSend.success(results)

            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, JSON.encode!(response))

          %{success: false, errors: errors} ->
            response = JSend.fail(errors)

            conn
            |> put_resp_content_type("application/json")
            |> send_resp(400, JSON.encode!(response))
        end

      {:error, reason} ->
        response = JSend.error("File upload failed", reason)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, JSON.encode!(response))
    end
  end

  get "/docs" do
    docs = %{
      title: "KurpoBot Diagnostic API",
      version: KurpoBot.version(),
      endpoints: %{
        "GET /health" => "Health check",
        "GET /export" => %{
          description: "Export all data and download as JSON file",
          note: "This may take a while for large datasets"
        },
        "POST /import" => %{
          description: "Import data from JSON export file (always clears existing data)",
          content_type: "multipart/form-data",
          form_field: "file",
          query_params: %{
            dry_run: "boolean (default: false) - validate only without importing"
          },
          note: "All existing data will be cleared and replaced with imported data"
        },
        "GET /docs" => "This documentation"
      }
    }

    response = JSend.success(docs)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, JSON.encode!(response))
  end

  match _ do
    response =
      JSend.error(
        "Not found",
        "The requested endpoint does not exist. See GET /docs for available endpoints."
      )

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, JSON.encode!(response))
  end

  # Private helper functions

  @spec parse_boolean(String.t() | nil, boolean()) :: boolean()
  defp parse_boolean(nil, default), do: default
  defp parse_boolean("true", _default), do: true
  defp parse_boolean("false", _default), do: false
  defp parse_boolean(_, default), do: default

  @spec get_uploaded_file(Plug.Conn.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp get_uploaded_file(conn) do
    case conn.body_params do
      %{"file" => %Plug.Upload{path: temp_path}} ->
        # Create a permanent copy of the uploaded file
        upload_dir = Path.join(:code.priv_dir(:kurpo_bot), "uploads")
        File.mkdir_p!(upload_dir)

        timestamp = DateTime.utc_now() |> DateTime.to_iso8601(:basic)
        permanent_path = Path.join(upload_dir, "upload_#{timestamp}.json")

        case File.cp(temp_path, permanent_path) do
          :ok -> {:ok, permanent_path}
          {:error, reason} -> {:error, "Failed to save uploaded file: #{inspect(reason)}"}
        end

      _ ->
        {:error, "No file uploaded. Expected multipart form with 'file' field."}
    end
  end
end

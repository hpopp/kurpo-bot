defmodule KurpoBot.Handler.Stats do
  alias Nostrum.Api
  alias Nostrum.Struct.Embed
  alias KurpoBot.Repo
  alias KurpoBot.Repo.Message
  require Logger

  @title "KurpoBot"
  @description "Basically the real Kurpo."
  @white 0xFFFFFF

  def handle_project_info(channel_id) do
    # Memory is returned in bytes
    memory = div(:erlang.memory(:total), 1_000_000)
    version = to_string(Application.spec(:kurpo_bot, :vsn))
    messages = Repo.total(Message)

    info = [
      {"Version", version},
      {"Library", "[KurpoBot](https://github.com/hpopp/kurpo-bot)"},
      {"Author", "hpopp\#5679"},
      {"Uptime", uptime() || "--"},
      {"Total Messages", "#{messages}"},
      {"Memory Usage", "#{memory} MB"}
    ]

    embed =
      %Embed{}
      |> Embed.put_title(@title)
      |> Embed.put_description(@description)
      |> Embed.put_color(@white)
      |> Embed.put_url("https://github.com/hpopp/kurpo-bot")
      |> put_fields(info, true)

    Api.create_message(channel_id, embed: embed)
  end

  def handle_sysinfo(channel_id) do
    memories = :erlang.memory()
    processes = length(:erlang.processes())
    {{_, io_input}, {_, io_output}} = :erlang.statistics(:io)

    mem_format = fn
      mem, :kb -> "#{div(mem, 1000)} KB"
      mem, :mb -> "#{div(mem, 1_000_000)} MB"
    end

    info = [
      {"Uptime", uptime()},
      {"Processes", "#{processes}"},
      {"Total Memory", mem_format.(memories[:total], :mb)},
      {"IO Input", mem_format.(io_input, :mb)},
      {"Process Memory", mem_format.(memories[:processes], :mb)},
      {"Code Memory", mem_format.(memories[:code], :mb)},
      {"IO Output", mem_format.(io_output, :mb)},
      {"ETS Memory", mem_format.(memories[:ets], :kb)},
      {"Atom Memory", mem_format.(memories[:atom], :kb)}
    ]

    embed =
      %Embed{}
      |> Embed.put_color(@white)
      |> put_fields(info, true)

    Api.create_message(channel_id, embed: embed)
  end

  defp put_fields(embed, fields, inline) do
    Enum.reduce(fields, embed, fn {name, value}, embed ->
      Embed.put_field(embed, name, value, inline)
    end)
  end

  # Returns a nicely formatted uptime string
  def uptime do
    {time, _} = :erlang.statistics(:wall_clock)
    min = div(time, 1000 * 60)
    {hours, min} = {div(min, 60), rem(min, 60)}
    {days, hours} = {div(hours, 24), rem(hours, 24)}

    Stream.zip([min, hours, days], ["m", "h", "d"])
    |> Enum.reduce("", fn
      {0, _glyph}, acc -> acc
      {t, glyph}, acc -> " #{t}" <> glyph <> acc
    end)
    |> case do
      "" -> "< 1m"
      val -> val
    end
  end
end

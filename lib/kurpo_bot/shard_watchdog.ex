defmodule KurpoBot.ShardWatchdog do
  @moduledoc """
  Monitors Nostrum shard processes and reconnects them when they've been
  permanently lost due to exhausted supervisor restart budgets.

  Nostrum.Shard uses `restart: :transient`, so when the per-shard supervisor
  reaches its max restart intensity (3 crashes in 60s), the DynamicSupervisor
  won't restart it. This watchdog detects that condition and re-establishes
  the connection with exponential backoff.
  """

  use GenServer
  require Logger

  defstruct consecutive_failures: 0,
            check_interval: :timer.seconds(30),
            initial_backoff: :timer.seconds(10),
            max_backoff: :timer.minutes(5)

  @type t :: %__MODULE__{
          consecutive_failures: non_neg_integer(),
          check_interval: pos_integer(),
          initial_backoff: pos_integer(),
          max_backoff: pos_integer()
        }

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    state = struct!(__MODULE__, opts)
    schedule_check(state)
    {:ok, state}
  end

  @impl true
  def handle_info(:check_shards, state) do
    state = check_and_recover(state)
    schedule_check(state)
    {:noreply, state}
  end

  @spec check_and_recover(t()) :: t()
  defp check_and_recover(state) do
    case DynamicSupervisor.count_children(Nostrum.Shard.Supervisor) do
      %{active: 0} ->
        Logger.warning("Shard watchdog: no active shards detected, attempting reconnect")
        attempt_reconnect(state)

      %{active: count} ->
        if state.consecutive_failures > 0 do
          Logger.info(
            "Shard watchdog: #{count} shard(s) active, recovered after " <>
              "#{state.consecutive_failures} failed attempt(s)"
          )
        end

        %{state | consecutive_failures: 0}
    end
  end

  @spec attempt_reconnect(t()) :: t()
  defp attempt_reconnect(state) do
    backoff =
      min(
        state.initial_backoff * Integer.pow(2, state.consecutive_failures),
        state.max_backoff
      )

    Logger.info(
      "Shard watchdog: backing off #{backoff}ms before reconnect " <>
        "(attempt #{state.consecutive_failures + 1})"
    )

    Process.sleep(backoff)

    {_url, total_shards} = Nostrum.Util.gateway()

    case Nostrum.Shard.Supervisor.connect(0, total_shards) do
      {:ok, _pid} ->
        Logger.info("Shard watchdog: successfully reconnected shard 0")
        %{state | consecutive_failures: 0}

      {:error, reason} ->
        Logger.error("Shard watchdog: reconnect failed: #{inspect(reason)}")
        %{state | consecutive_failures: state.consecutive_failures + 1}
    end
  end

  @spec schedule_check(t()) :: reference()
  defp schedule_check(state) do
    Process.send_after(self(), :check_shards, state.check_interval)
  end
end

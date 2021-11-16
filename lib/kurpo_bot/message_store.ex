defmodule KurpoBot.MessageStore do
  use GenServer

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, %{messages: []}}
  end

  def put_messages(messages) do
    GenServer.call(__MODULE__, {:put_messages, messages})
  end

  def get_random() do
    GenServer.call(__MODULE__, :get_random)
  end

  def handle_call({:put_messages, messages}, _from, state) do
    {:reply, :ok, Map.put(state, :messages, messages)}
  end

  def handle_call(:get_random, _from, %{messages: []} = state) do
    {:reply, {:ok, nil}, state}
  end

  def handle_call(:get_random, _from, state) do
    message = Enum.random(state[:messages])
    {:reply, {:ok, message}, state}
  end
end

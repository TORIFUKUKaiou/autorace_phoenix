defmodule AutoracePhoenix.Autorace.Cache do
  use GenServer

  @update_interval 60 * 60 * 24

  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: __MODULE__)
  end

  def init(_) do
    state = %{events: [], timer: nil, time: DateTime.now!("Etc/UTC")}
    {:ok, new_state(state)}
  end

  def handle_info(:update, state) do
    {:noreply, new_state(state)}
  end

  def handle_call(:events, _from, %{events: events} = state) do
    {:reply, events, state}
  end

  def events do
    GenServer.call(__MODULE__, :events)
  end

  defp new_state(state) do
    new_events = AutoracePhoenix.Autorace.GetEvents.run()

    {interval, new_events} =
      if Enum.empty?(new_events), do: {60, state.events}, else: {@update_interval, new_events}

    %{
      events: new_events,
      timer: Process.send_after(self(), :update, interval),
      time: DateTime.now!("Etc/UTC")
    }
  end
end

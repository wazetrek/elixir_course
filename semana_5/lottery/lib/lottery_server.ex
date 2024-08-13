defmodule Lottery.Server do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, Lottery.new(), name: __MODULE__)
  end

  @doc """
  Adds a player to the lottery.

  ## Examples

      iex> Lottery.Server.add_player("Andrés")
      :ok
  """
  def add_player(player) do
    GenServer.call(__MODULE__, {:add_player, player})
  end

  def publish_results(results) do
    GenServer.cast(__MODULE__, {:publish_results, results})
  end

  def notify_winner() do
    GenServer.call(__MODULE__, :notify_winner)
  end

  @impl true
  def init(lottery) do
    {:ok, lottery}
  end

  @impl true
  def handle_call({:add_player, player}, _from, %Lottery{players: players} = lottery) do
    if player in players do
      {:reply, {:error, :player_already_registered}, lottery}
    else
      new_lottery = Lottery.add_player(lottery, player)
      {:reply, :ok, new_lottery}
    end
  end

  @impl true
  def handle_call(:notify_winner, _from, %Lottery{players: players, results: results} = lottery) do
    cond do
      length(players) == 0 ->
        {:reply, {:error, :no_players_registered}, lottery}

      is_nil(results) ->
        {:reply, {:error, :results_not_published}, lottery}

      true ->
        winner = Lottery.notify_winner(lottery)
        {:reply, {:ok, winner}, lottery}
    end
  end

  @impl true
  def handle_cast({:publish_results, results}, %Lottery{players: players} = lottery) do
    IO.puts("players registered: #{length(players)}")
    if length(players) == 0 do
      {:noreply, lottery}
    else
      new_lottery = Lottery.set_results(lottery, results)
      {:noreply, new_lottery}
    end
  end
end

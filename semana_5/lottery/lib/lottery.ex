defmodule Lottery do
  defstruct players: [], results: nil

  def new() do
    %Lottery{}
  end

  def add_player(lottery, player) do
    %{lottery | players: [player | lottery.players]}
  end

  def set_results(lottery, results) do
    %{lottery | results: results}
  end

  def notify_winner(lottery) do
    winner = Enum.random(lottery.players)
    IO.puts("El ganador es: #{winner}")
    winner
  end
end

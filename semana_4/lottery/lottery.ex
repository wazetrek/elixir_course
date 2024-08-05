defmodule Lottery do

  def start do
    spawn(fn -> loop([]) end)
  end

  def subscribe(lottery_pid, player) do
    send(lottery_pid, {:subscribe, player})
  end

  def raffle(lottery_pid, winnerNumber) do
    send(lottery_pid, {:lottery, winnerNumber})
  end

  def loop(players) do
    receive do
      {:subscribe, player} ->
        IO.puts("Nuevo participante agregado")
        loop([player | players])

      {:lottery, winnerNumber} ->
        IO.puts("Número ganador en la lotería: #{winnerNumber}")
        Enum.each(players, fn player -> send(player, {:lottery, winnerNumber}) end)
        loop(players)
      {:stop} ->
        IO.puts("Lotería finalizada")
      {:list} ->
        IO.puts("Participantes:")
        Enum.each(players, fn player -> IO.puts("#{inspect player} ") end)
        loop(players)
      _ ->
        IO.puts("Invalid Message")
        loop(players)
    end
  end

end

defmodule Player do

  def start(name, ticket) do
    spawn(fn -> loop(name, ticket) end)
  end

  def loop(name, ticket) do
    receive do
      {:lottery, winnerNumber} ->
        if ticket == winnerNumber do
          IO.puts("#{name}: Ganaste! con el número #{ticket}")
        else
          IO.puts("#{name}: Perdiste! tú número: #{ticket}, número ganador: #{winnerNumber}")
        end
        loop(name, ticket)
      _ ->
        IO.puts("Invalid Message")
        loop(name, ticket)
    end
  end
end

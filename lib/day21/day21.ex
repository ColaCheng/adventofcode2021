defmodule Day21 do
  @input_file "./lib/day21/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :all)
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {e, index} ->
      [_, start_at] = String.split(e, ": ")
      {index, String.to_integer(start_at), 0}
    end)
    |> play({[1, 2, 3], 0}, [])
  end

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    players =
      IO.read(file, :all)
      |> String.split("\n", trim: true)
      |> Enum.with_index(1)
      |> Enum.map(fn {e, index} ->
        [_, start_at] = String.split(e, ": ")
        {index, {String.to_integer(start_at), 0}}
      end)
      |> Map.new()

    universa = [{players, 1}]

    play2(universa, %{1 => 0, 2 => 0})
    |> Enum.map(fn {_, score} -> score end)
    |> Enum.max()
  end

  defp play([{index, pos, score} | tail], {dice, rolled_time}, acc) do
    {dice, sum} =
      Enum.map_reduce(dice, 0, fn n, acc ->
        {rem(n + 3, 100), n + acc}
      end)

    pos = rem(pos + sum - 1, 10) + 1
    rolled_time = rolled_time + 3

    case score + pos do
      score when score >= 1000 ->
        last_score = elem(hd(acc), 2)
        rolled_time * last_score

      score ->
        play(tail, {dice, rolled_time}, [{index, pos, score} | acc])
    end
  end

  defp play([], dice, acc) do
    play(Enum.reverse(acc), dice, [])
  end

  defp play2(universa, wins) do
    {universa, wins} =
      Enum.flat_map_reduce(universa, wins, fn {players, num_parents}, wins ->
        do_one(players, num_parents, 1, wins)
      end)

    universa = consolidate(universa)

    {universa, wins} =
      Enum.flat_map_reduce(universa, wins, fn {players, num_parents}, wins ->
        do_one(players, num_parents, 2, wins)
      end)

    universa = consolidate(universa)

    case universa do
      [] ->
        wins

      _ ->
        play2(Enum.uniq(universa), wins)
    end
  end

  defp do_one(state, num_parents, player_id, wins) do
    outcomes = play_one(state, player_id, num_parents)
    process_won(outcomes, wins, player_id)
  end

  defp process_won(outcomes, wins, player_id) do
    {ongoing, won} =
      Enum.split_with(outcomes, fn {state, _} ->
        Map.fetch!(state, player_id) !== :win
      end)

    num_won =
      Enum.map(won, fn {_, num_universa} -> num_universa end)
      |> Enum.sum()

    wins = Map.update!(wins, player_id, &(&1 + num_won))

    {ongoing, wins}
  end

  defp consolidate(universa) do
    universa
    |> Enum.group_by(fn {state, _} -> state end)
    |> Enum.map(fn {state, list} ->
      sum =
        Enum.map(list, fn {_, freq} -> freq end)
        |> Enum.sum()

      {state, sum}
    end)
  end

  defp play_one(state, player_id, num_parents) do
    roll3()
    |> Enum.map(fn {steps, num_universa} ->
      num_universa = num_universa * num_parents
      {pos, score} = Map.fetch!(state, player_id)
      pos = rem(pos + steps - 1, 10) + 1
      score = score + pos

      player_state =
        if score >= 21 do
          :win
        else
          {pos, score}
        end

      {Map.put(state, player_id, player_state), num_universa}
    end)
  end

  defp roll3() do
    Enum.flat_map(1..3, fn roll1 ->
      Enum.flat_map(1..3, fn roll2 ->
        Enum.map(1..3, fn roll3 ->
          [roll1, roll2, roll3]
        end)
      end)
    end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.frequencies()
  end
end

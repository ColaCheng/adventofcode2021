defmodule Day4 do
  @input_file "./lib/day4/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    [draw_numbers_string | boards_string] =
      IO.read(file, :all)
      |> String.split("\n\n", trim: true)

    draw_numbers =
      String.split(draw_numbers_string, ",")
      |> Enum.map(&String.to_integer/1)

    boards =
      gen_boards(boards_string, [])
      |> Enum.reverse()

    {_, {last_number, draws, board}} = play_first_win(draw_numbers, boards)

    Map.drop(board, draws)
    |> Map.keys()
    |> Enum.sum()
    |> Kernel.*(last_number)
  end

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    [draw_numbers_string | boards_string] =
      IO.read(file, :all)
      |> String.split("\n\n", trim: true)

    draw_numbers =
      String.split(draw_numbers_string, ",")
      |> Enum.map(&String.to_integer/1)

    boards =
      gen_boards(boards_string, [])
      |> Enum.reverse()

    {_, {last_number, draws, board}} = play_last_win(draw_numbers, boards)

    Map.drop(board, draws)
    |> Map.keys()
    |> Enum.sum()
    |> Kernel.*(last_number)
  end

  defp gen_boards([board_string | tail], acc) do
    {board, _} =
      String.split(board_string, "\n", trim: true)
      |> Enum.reduce({%{}, 0}, fn e, {board, position} ->
        new_board =
          String.split(e, " ", trim: true)
          |> Enum.reduce({[], 0}, fn e, {acc, index} ->
            {[{String.to_integer(e), {index, position}} | acc], index + 1}
          end)
          |> elem(0)
          |> Map.new()
          |> Map.merge(board)

        {new_board, position + 1}
      end)

    gen_boards(tail, [{board, %{}} | acc])
  end

  defp gen_boards([], acc), do: acc

  defp play_first_win([draw_number | tail], boards) do
    case Enum.reduce_while(boards, {nil, []}, fn {board, statistic}, {_, acc} ->
           case play(draw_number, board, statistic) do
             {nil, statistic} ->
               {:cont, {nil, [{board, statistic} | acc]}}

             {:bingo, statistic} ->
               {:halt, {:bingo, {draw_number, Map.get(statistic, :draw, []), board}}}
           end
         end) do
      {nil, boards} -> play_first_win(tail, Enum.reverse(boards))
      {:bingo, result} -> {:bingo, result}
    end
  end

  defp play_first_win([], _), do: nil

  defp play_last_win([draw_number | tail], boards) do
    case Enum.reduce(boards, {nil, []}, fn {board, statistic}, {previous_bingo, board_acc} ->
           case play(draw_number, board, statistic) do
             {nil, statistic} ->
               {previous_bingo, [{board, statistic} | board_acc]}

             {:bingo, statistic} ->
               {{draw_number, Map.get(statistic, :draw, []), board}, board_acc}
           end
         end) do
      {last_bingo, []} -> {:last_bingo, last_bingo}
      {_, boards} -> play_last_win(tail, Enum.reverse(boards))
    end
  end

  defp play_last_win([], _), do: nil

  defp play(draw_number, board, statistic) do
    case Map.get(board, draw_number, nil) do
      nil ->
        {nil, statistic}

      coordinate ->
        statistic1 = draw_number({coordinate, draw_number}, statistic)

        case is_bingo?(statistic1) do
          false -> {nil, statistic1}
          true -> {:bingo, statistic1}
        end
    end
  end

  defp is_bingo?(statistic) do
    Map.drop(statistic, [:draw])
    |> Map.values()
    |> is_bingo?(false)
  end

  defp is_bingo?([line | _tail], _) when length(line) == 5 do
    true
  end

  defp is_bingo?([_line | tail], acc) do
    is_bingo?(tail, acc)
  end

  defp is_bingo?([], acc), do: acc

  defp draw_number(coordinate, statistic) do
    update_line(coordinate, statistic)
  end

  defp update_line({_, number} = record, statistic) do
    statistic1 = update_x_line(record, statistic)
    statistic2 = update_y_line(record, statistic1)

    Map.update(statistic2, :draw, [number], fn draw_numbers ->
      draw_numbers ++ [number]
    end)
  end

  defp update_x_line({{x, _y}, _number} = draw, statistic) do
    key =
      :erlang.iolist_to_binary(["x", Integer.to_string(x)])
      |> String.to_atom()

    Map.update(statistic, key, [draw], fn v ->
      [draw | v]
    end)
  end

  defp update_y_line({{_x, y}, _number} = draw, statistic) do
    key =
      :erlang.iolist_to_binary(["y", Integer.to_string(y)])
      |> String.to_atom()

    Map.update(statistic, key, [draw], fn v ->
      [draw | v]
    end)
  end
end

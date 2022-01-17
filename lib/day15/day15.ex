defmodule Day15 do
  @input_file "./lib/day15/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, {[], 0}, &process/2)
    |> elem(0)
    |> Map.new()
    |> travel()
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp convert(raw) do
    String.split(raw, [" -> ", "\n"], trim: true)
    |> hd()
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
  end

  defp process(data, {acc, row}) do
    acc =
      Enum.reduce(data, {acc, 0}, fn e, {acc, column} ->
        {[{{row, column}, e} | acc], column + 1}
      end)
      |> elem(0)

    {acc, row + 1}
  end

  defp travel(map) do
    goal = find_lower_right(map)
    start = {0, 0}
    q = :gb_sets.singleton({0, start})
    best = nil
    seen = MapSet.new()
    travel(q, map, best, goal, seen)
  end

  defp find_lower_right(map) do
    {{x_max, _}, _} = Enum.max_by(map, &elem(elem(&1, 0), 0))
    {{_, y_max}, _} = Enum.max_by(map, &elem(elem(&1, 0), 1))
    {x_max, y_max}
  end

  defp travel(q, map, best, goal, seen) do
    case :gb_sets.is_empty(q) do
      true ->
        best

      false ->
        {element, q} = :gb_sets.take_smallest(q)

        case element do
          {risk, _} when risk >= best ->
            travel(q, map, best, goal, seen)

          {risk, position} ->
            seen = MapSet.put(seen, position)

            case position do
              ^goal ->
                travel(q, map, risk, goal, seen)

              _ ->
                q =
                  neighbors(map, position)
                  |> Enum.reduce(q, fn pos, q ->
                    case MapSet.member?(seen, pos) do
                      true ->
                        q

                      false ->
                        element = {risk + Map.fetch!(map, pos), pos}
                        :gb_sets.add(element, q)
                    end
                  end)

                travel(q, map, best, goal, seen)
            end
        end
    end
  end

  defp neighbors(map, {x, y}) do
    [{x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1}]
    |> Enum.filter(&Map.has_key?(map, &1))
  end
end

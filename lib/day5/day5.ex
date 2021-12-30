defmodule Day5 do
  @input_file "./lib/day5/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, %{}, &process/2)
    |> Enum.reduce(0, fn {_k, v}, count ->
      case v do
        v when v >= 2 -> count + 1
        _ -> count
      end
    end)
  end

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, %{}, &process2/2)
    |> Enum.reduce(0, fn {_k, v}, count ->
      case v do
        v when v >= 2 -> count + 1
        _ -> count
      end
    end)
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp convert(raw) do
    [from, to] =
      raw
      |> String.split(" -> ", trim: true)
      |> Enum.map(fn e ->
        [x, y] =
          String.split(e, ",", trim: true)
          |> Enum.map(&String.trim/1)

        {String.to_integer(x), String.to_integer(y)}
      end)

    {from, to}
  end

  defp process({{x, y1}, {x, y2}}, statistic) do
    y_range = Enum.to_list(y1..y2)

    merge([x], y_range, [])
    |> Enum.reduce(statistic, fn coordinate, acc ->
      Map.update(acc, coordinate, 1, fn count ->
        count + 1
      end)
    end)
  end

  defp process({{x1, y}, {x2, y}}, statistic) do
    x_range = Enum.to_list(x1..x2)

    merge(x_range, [y], [])
    |> Enum.reduce(statistic, fn coordinate, acc ->
      Map.update(acc, coordinate, 1, fn count ->
        count + 1
      end)
    end)
  end

  defp process(_, statistic), do: statistic

  defp process2({{x1, y1}, {x2, y2}}, statistic) when abs(x1 - x2) == abs(y1 - y2) do
    Enum.to_list(x1..x2)
    |> Enum.zip(Enum.to_list(y1..y2))
    |> Enum.reduce(statistic, fn coordinate, acc ->
      Map.update(acc, coordinate, 1, fn count ->
        count + 1
      end)
    end)
  end

  defp process2({{x, y1}, {x, y2}}, statistic) do
    y_range = Enum.to_list(y1..y2)

    merge([x], y_range, [])
    |> Enum.reduce(statistic, fn coordinate, acc ->
      Map.update(acc, coordinate, 1, fn count ->
        count + 1
      end)
    end)
  end

  defp process2({{x1, y}, {x2, y}}, statistic) do
    x_range = Enum.to_list(x1..x2)

    merge(x_range, [y], [])
    |> Enum.reduce(statistic, fn coordinate, acc ->
      Map.update(acc, coordinate, 1, fn count ->
        count + 1
      end)
    end)
  end

  defp process2(_, statistic), do: statistic

  defp merge([x | x_tail], y_range, acc) do
    new_acc = Enum.reduce(y_range, acc, fn y, acc -> [{x, y} | acc] end)
    merge(x_tail, y_range, new_acc)
  end

  defp merge([], _y_range, acc), do: acc
end

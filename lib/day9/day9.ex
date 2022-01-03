defmodule Day9 do
  @input_file "./lib/day9/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, {0, []}, &process/2)
    |> elem(1)
    |> Map.new()
    |> find_low_points()
    |> Enum.reduce(0, &(elem(&1, 1) + 1 + &2))
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp convert(raw) do
    String.trim(raw)
  end

  defp process(data, {y, acc}) do
    {y + 1, summary(data, y, {0, acc})}
  end

  defp summary("", _y, {_, acc}), do: acc

  defp summary(<<n::binary-size(1), rest::binary>>, y, {x, acc}) do
    summary(rest, y, {x + 1, [{{x, y}, String.to_integer(n)} | acc]})
  end

  defp find_low_points(summary) do
    Enum.filter(summary, fn {{x, y}, n} ->
      neighbors(summary, {x, y})
      |> Enum.all?(&(Map.get(summary, &1) > n))
    end)
  end

  defp neighbors(summary, {x, y}) do
    [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
    |> Enum.filter(&Map.has_key?(summary, &1))
  end
end

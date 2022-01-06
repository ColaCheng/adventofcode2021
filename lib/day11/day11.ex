defmodule Day11 do
  @input_file "./lib/day11/input"

  def run1(round \\ 100) do
    {:ok, file} = File.open(@input_file, [:read])

    grid =
      IO.read(file, :line)
      |> read_line_reduce(file, {0, []}, &process/2)
      |> elem(1)
      |> Map.new()

    progress(round, grid, 0)
    |> elem(1)
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

  defp process(line, {y, acc}) do
    {y + 1, summary(line, 0, y, acc)}
  end

  defp summary("", _x, _y, acc), do: acc

  defp summary(<<n::binary-size(1), rest::binary>>, x, y, acc) do
    summary(rest, x + 1, y, [{{x, y}, String.to_integer(n)} | acc])
  end

  defp neighbors({x, y}, grid) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
    |> Enum.filter(&Map.has_key?(grid, &1))
  end

  defp progress(0, map, acc), do: {map, acc}

  defp progress(round, grid, num_flashes) do
    grid =
      Enum.map(grid, fn {k, v} -> {k, v + 1} end)
      |> Map.new()

    flashes = Enum.filter(Map.keys(grid), fn k -> Map.get(grid, k) > 9 end)
    num_flashes = num_flashes + length(flashes)
    {grid, num_flashes} = flash(grid, flashes, num_flashes)

    grid =
      Enum.map(grid, fn
        {key, energy} when energy < 0 -> {key, 0}
        v -> v
      end)
      |> Map.new()

    progress(round - 1, grid, num_flashes)
  end

  defp flash(grid, [_ | _] = flashes, num_flashes) do
    grid =
      Enum.reduce(flashes, grid, fn key, grid ->
        Map.put(grid, key, -1_000_000)
      end)

    {grid, flashes} = Enum.reduce(flashes, {grid, []}, &flash_one/2)
    flashes = Enum.uniq(flashes)
    flash(grid, flashes, num_flashes + length(flashes))
  end

  defp flash(grid, [], num_flashes), do: {grid, num_flashes}

  defp flash_one(key, {grid, flashes}) do
    Enum.reduce(neighbors(key, grid), {grid, flashes}, fn neighbor, {grid, flashes} ->
      energy = Map.get(grid, neighbor) + 1
      grid = Map.put(grid, neighbor, energy)

      {grid, (energy > 9 && [neighbor | flashes]) || flashes}
    end)
  end
end

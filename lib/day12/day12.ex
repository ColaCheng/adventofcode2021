defmodule Day12 do
  @input_file "./lib/day12/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, [], &process/2)
    |> Enum.uniq()
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> paths()
    |> resolve([])
    |> length()
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp convert(raw) do
    String.split(raw, ["-", "\n"], trim: true)
  end

  defp process([from, to], edges) do
    [{from, to}, {to, from} | edges]
  end

  defp paths(%{"start" => caves} = map) do
    Enum.map(caves, &traverse(&1, map, []))
  end

  defp traverse("end", _map, acc) do
    ["end" | acc]
  end

  defp traverse("start", _map, acc) do
    acc
  end

  defp traverse(nil, _map, acc) do
    acc
  end

  defp traverse(cave, map, acc) do
    nexts = Map.get(map, cave, [])

    case {String.downcase(cave), Enum.member?(acc, cave)} do
      {^cave, true} ->
        acc

      _ ->
        Enum.map(nexts, &traverse(&1, map, [cave | acc]))
    end
  end

  defp resolve(["end" | _] = path, acc) do
    [path | acc]
  end

  defp resolve([cave | _caves], acc) when is_binary(cave) do
    acc
  end

  defp resolve([path | paths], acc) do
    resolve(paths, resolve(path, acc))
  end

  defp resolve([], acc) do
    acc
  end
end

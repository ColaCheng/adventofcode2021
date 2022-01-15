defmodule Day14 do
  @input_file "./lib/day14/input"

  def run1(steps \\ 10) do
    {:ok, file} = File.open(@input_file, [:read])

    {template, rules} =
      IO.read(file, :line)
      |> read_line_reduce(file, {nil, []}, &process/2)

    rules = Map.new(rules)

    {{_, min}, {_, max}} =
      String.codepoints(template)
      |> Stream.iterate(&next_step(&1, rules))
      |> Stream.drop(steps)
      |> Stream.take(1)
      |> Enum.to_list()
      |> hd()
      |> Enum.frequencies()
      |> Enum.min_max_by(&elem(&1, 1))

    max - min
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp convert("\n"), do: nil

  defp convert(raw) do
    case String.split(raw, [" -> ", "\n"], trim: true) do
      [pair1, pair2] ->
        {pair1, pair2}

      [template] ->
        template
    end
  end

  defp process(nil, acc), do: acc

  defp process(data, {template, pairs}) do
    case data do
      pair when is_tuple(pair) -> {template, [pair | pairs]}
      _ -> {data, pairs}
    end
  end

  defp next_step(template, rules) do
    pair_insertion(template, rules, [])
  end

  defp pair_insertion([a, b | rest], rules, acc) do
    next = [b | rest]

    case Map.get(rules, a <> b) do
      nil -> pair_insertion(next, rules, [a | acc])
      insert -> pair_insertion(next, rules, [insert, a | acc])
    end
  end

  defp pair_insertion([e], _pairs, acc) do
    Enum.reverse([e | acc])
  end
end

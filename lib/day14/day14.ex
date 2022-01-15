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

  def run2(steps \\ 40) do
    {:ok, file} = File.open(@input_file, [:read])

    {template, rules} =
      IO.read(file, :line)
      |> read_line_reduce(file, {nil, []}, &process/2)

    rules = Map.new(rules)
    template = String.codepoints(template)

    pairs =
      Enum.zip(template, tl(template))
      |> Enum.frequencies()

    letters = Enum.frequencies(template)

    {{_, min}, {_, max}} =
      Stream.iterate({pairs, letters}, &next_step2(&1, rules))
      |> Stream.drop(steps)
      |> Stream.take(1)
      |> Enum.to_list()
      |> hd()
      |> elem(1)
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

  defp next_step2({old_pairs, letters}, rules) do
    Enum.reduce(rules, {old_pairs, letters}, fn {<<a::binary-size(1), b::binary-size(1)>>, c},
                                                {pairs, letters} ->
      count = Map.get(old_pairs, {a, b}, 0)

      pairs =
        pairs
        |> Map.update({a, b}, -count, &(&1 - count))
        |> Map.update({a, c}, count, &(&1 + count))
        |> Map.update({c, b}, count, &(&1 + count))

      letters = Map.update(letters, c, count, &(&1 + count))
      {pairs, letters}
    end)
  end
end

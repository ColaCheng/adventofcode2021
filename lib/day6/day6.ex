defmodule Day6 do
  @input_file "./lib/day6/input"

  def run1(days) do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :all)
    |> parse()
    |> prepare()
    |> consolidate()
    |> Stream.iterate(&next/1)
    |> Stream.drop(days)
    |> Enum.take(1)
    |> hd()
    |> Enum.reduce(0, &(elem(&1, 1) + &2))
  end

  def run2(days) do
    run1(days)
  end

  defp parse(raw) do
    String.split(raw, ",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp prepare(fishes) do
    Enum.map(fishes, &({&1, 1}))
  end

  defp consolidate(fishes) do
    Enum.group_by(fishes, &(elem(&1, 0)))
    |> Enum.map(fn {timer, counts} ->
      sum = Enum.map(counts, &(elem(&1, 1)))
      |> Enum.sum()
      {timer, sum}
    end)
  end

  defp next(fishes) do
    {fishes1, new} = Enum.map_reduce(fishes, 0, fn({timer, n}, acc) ->
      case timer do
        0 -> {{6, n}, acc + n}
        _ -> {{timer - 1, n}, acc}
      end
    end)
    consolidate([{8, new} | fishes1])
  end
end

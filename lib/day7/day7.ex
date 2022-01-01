defmodule Day7 do
  @input_file "./lib/day7/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :all)
    |> parse()
    |> Enum.frequencies()
    |> Map.to_list()
    |> Enum.sort()
    |> find_the_lowest_cost()
  end

  defp parse(raw) do
    String.split(raw, ",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp find_the_lowest_cost([{from_at, _} | _] = crabs) do
    {end_at, _} = Enum.at(crabs, -1)
    find_the_lowest_cost(crabs, from_at + 1, end_at, {from_at, count_cost(crabs, from_at)})
  end

  defp find_the_lowest_cost(crabs, align_at, end_at, {last_align_at, last_cost})
       when end_at >= align_at do
    cost = count_cost(crabs, align_at)

    case last_cost > cost do
      true -> find_the_lowest_cost(crabs, align_at + 1, end_at, {align_at, cost})
      _ -> find_the_lowest_cost(crabs, align_at + 1, end_at, {last_align_at, last_cost})
    end
  end

  defp find_the_lowest_cost(_, _, _, acc), do: acc

  defp count_cost(crabs, align_at) do
    Enum.reduce(crabs, 0, &(abs(elem(&1, 0) - align_at) * elem(&1, 1) + &2))
  end
end

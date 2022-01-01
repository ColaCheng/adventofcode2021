defmodule Day7 do
  @input_file "./lib/day7/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :all)
    |> parse()
    |> Enum.frequencies()
    |> Map.to_list()
    |> Enum.sort()
    |> find_the_lowest_cost(&count_cost/2)
  end

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :all)
    |> parse()
    |> Enum.frequencies()
    |> Map.to_list()
    |> Enum.sort()
    |> find_the_lowest_cost(&count_cost2/2)
  end

  defp parse(raw) do
    String.split(raw, ",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp find_the_lowest_cost([{from_at, _} | _] = crabs, cost_fun) do
    {end_at, _} = Enum.at(crabs, -1)

    find_the_lowest_cost(
      crabs,
      from_at + 1,
      end_at,
      cost_fun,
      {from_at, cost_fun.(crabs, from_at)}
    )
  end

  defp find_the_lowest_cost(crabs, align_at, end_at, cost_fun, {last_align_at, last_cost})
       when end_at >= align_at do
    cost = cost_fun.(crabs, align_at)

    case last_cost > cost do
      true -> find_the_lowest_cost(crabs, align_at + 1, end_at, cost_fun, {align_at, cost})
      _ -> find_the_lowest_cost(crabs, align_at + 1, end_at, cost_fun, {last_align_at, last_cost})
    end
  end

  defp find_the_lowest_cost(_, _, _, _, acc), do: acc

  defp count_cost(crabs, align_at) do
    Enum.reduce(crabs, 0, &(abs(elem(&1, 0) - align_at) * elem(&1, 1) + &2))
  end

  defp count_cost2(crabs, align_at) do
    Enum.reduce(crabs, 0, fn {position, n}, acc ->
      case align_at do
        ^position ->
          acc

        _ ->
          diff = abs(align_at - position)

          Enum.sum(1..diff)
          |> Kernel.*(n)
          |> Kernel.+(acc)
      end
    end)
  end
end

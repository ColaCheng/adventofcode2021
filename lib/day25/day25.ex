defmodule Day25 do
  @input_file "./lib/day25/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    grid =
      IO.read(file, :all)
      |> parse()

    Stream.iterate(grid, &move/1)
    |> Stream.with_index()
    |> Stream.drop_while(&elem(&1, 0))
    |> Enum.take(1)
    |> hd()
    |> elem(1)
  end

  defp move(grid) do
    case move_one(grid, :east) do
      nil ->
        move_one(grid, :south)

      grid ->
        move_one(grid, :south) || grid
    end
  end

  defp move_one(grid, kind) do
    case moves(grid, kind) do
      [] ->
        nil

      moves ->
        Enum.reduce(moves, grid, fn {from, to}, grid ->
          %{grid | from => :empty, to => kind}
        end)
    end
  end

  defp moves(grid, kind) do
    Enum.reduce(Enum.sort(grid), [], fn {from, what}, acc ->
      if kind === what do
        case get_adjacent(grid, kind, from) do
          {to, :empty} ->
            [{from, to} | acc]

          {_, _} ->
            acc
        end
      else
        acc
      end
    end)
  end

  defp get_adjacent(grid, :east, {row, col}) do
    pos = {row, col + 1}

    case Map.get(grid, pos) do
      nil ->
        pos = {row, 0}
        {pos, Map.fetch!(grid, pos)}

      what ->
        {pos, what}
    end
  end

  defp get_adjacent(grid, :south, {row, col}) do
    pos = {row + 1, col}

    case Map.get(grid, pos) do
      nil ->
        pos = {0, col}
        {pos, Map.fetch!(grid, pos)}

      what ->
        {pos, what}
    end
  end

  defp parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      String.codepoints(line)
      |> Enum.with_index()
      |> Enum.map(fn {char, col} ->
        {{row, col},
         case char do
           "v" -> :south
           ">" -> :east
           "." -> :empty
         end}
      end)
    end)
    |> Map.new()
  end
end

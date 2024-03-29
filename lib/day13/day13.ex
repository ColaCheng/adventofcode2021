defmodule Day13 do
  @input_file "./lib/day13/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    {coordinates, folds} =
      IO.read(file, :line)
      |> read_line_reduce(file, {[], []}, &process/2)

    [fold | _folds] = Enum.reverse(folds)

    Enum.reduce(coordinates, [], fn
      coordinate, acc ->
        case fold(coordinate, fold) do
          nil -> acc
          coordinate -> [coordinate | acc]
        end
    end)
    |> MapSet.new()
    |> MapSet.size()
  end

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    {coordinates, folds} =
      IO.read(file, :line)
      |> read_line_reduce(file, {[], []}, &process/2)

    folds = Enum.reverse(folds)

    Enum.reduce(folds, coordinates, fn fold_i, coordinates ->
      Enum.reduce(coordinates, [], fn
        coordinate, acc ->
          case fold(coordinate, fold_i) do
            nil -> acc
            coordinate -> [coordinate | acc]
          end
      end)
    end)
    |> MapSet.new()
    |> print()
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
    case String.split(raw, ["fold", "along", "=", " ", ",", "\n"], trim: true) do
      [fold, line] when fold in ["x", "y"] ->
        {String.to_atom(fold), String.to_integer(line)}

      [x, y] ->
        {String.to_integer(x), String.to_integer(y)}
    end
  end

  defp process(nil, acc), do: acc

  defp process(data, {coordinates, folds}) do
    case data do
      {fold, _} when is_atom(fold) -> {coordinates, [data | folds]}
      _ -> {[data | coordinates], folds}
    end
  end

  defp fold({x, _y}, {:x, x}), do: nil
  defp fold({_x, y}, {:y, y}), do: nil
  defp fold({x, y}, {:x, line}) when x > line, do: {line - (x - line), y}
  defp fold({x, y}, {:y, line}) when y > line, do: {x, line - (y - line)}
  defp fold(coordinate, _), do: coordinate

  defp print(coordinates) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(coordinates, &elem(&1, 0))
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(coordinates, &elem(&1, 1))
    :io.nl()

    Enum.each(min_x..max_x, fn x ->
      Enum.map(min_y..max_y, fn y ->
        case MapSet.member?(coordinates, {x, y}) do
          true -> ?#
          false -> ?.
        end
      end)
      |> IO.puts()
    end)

    :io.nl()
  end
end

defmodule Day2 do
  @input_file "./lib/day2/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    {x, z} =
      IO.read(file, :line)
      |> read_line_reduce(file, {0, 0}, &sail/2)

    x * z
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(to_command(raw), acc), reducer)
  end

  defp to_command(raw) do
    [command, unit] =
      raw
      |> String.split(" ")

    {command, String.to_integer(String.trim(unit))}
  end

  defp sail({"forward", unit}, {horizontal_position, depth}) do
    {horizontal_position + unit, depth}
  end

  defp sail({"up", unit}, {horizontal_position, depth}) do
    new_depth =
      case depth - unit do
        r when r < 0 -> 0
        r -> r
      end

    {horizontal_position, new_depth}
  end

  defp sail({"down", unit}, {horizontal_position, depth}) do
    {horizontal_position, depth + unit}
  end
end

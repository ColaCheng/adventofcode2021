defmodule Day8 do
  @input_file "./lib/day8/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, %{}, &process/2)
    |> Enum.reduce(0, &(elem(&1, 1) + &2))
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp convert(raw) do
    [signals, outputs] =
      raw
      |> String.split(" | ", trim: true)
      |> Enum.map(&String.split(&1, [" ", "\n"], trim: true))

    {signals, outputs}
  end

  defp process({_signals, outputs}, acc) do
    Enum.reduce(outputs, acc, fn digits, acc ->
      case determine_number(digits) do
        nil -> acc
        number -> Map.update(acc, number, 1, &(&1 + 1))
      end
    end)
  end

  defp determine_number(digits) when byte_size(digits) == 2, do: 1
  defp determine_number(digits) when byte_size(digits) == 3, do: 7
  defp determine_number(digits) when byte_size(digits) == 4, do: 4
  defp determine_number(digits) when byte_size(digits) == 7, do: 8
  defp determine_number(_digits), do: nil
end

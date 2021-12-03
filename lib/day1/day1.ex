defmodule Day1 do
  @input_file "./lib/day1/input"

  def run() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, {nil, 0}, &count_larger_than_previous_measurement/2)
    |> elem(1)
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp convert(raw) do
    raw
    |> String.trim_trailing()
    |> String.to_integer()
  end

  defp count_larger_than_previous_measurement(now, {last, acc}) when now > last do
    {now, acc + 1}
  end

  defp count_larger_than_previous_measurement(now, {_last, acc}) do
    {now, acc}
  end
end

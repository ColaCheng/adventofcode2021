defmodule Day3 do
  @input_file "./lib/day3/input"

  use Bitwise

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    {gamma_rare, epislon} =
      IO.read(file, :line)
      |> read_line_reduce(file, %{}, &diagnose/2)
      |> report(0, "")

    gamma_rare * epislon
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp convert(raw) do
    String.trim(raw)
  end

  defp diagnose(number, acc) do
    parse_number(number, 0, acc)
  end

  defp parse_number(<<f::binary-size(1), rest::binary>>, position, summary) do
    {low, high} = Map.get(summary, position, {0, 0})

    new_position_summary =
      case f do
        "0" -> {low + 1, high}
        "1" -> {low, high + 1}
      end

    parse_number(rest, position + 1, Map.put(summary, position, new_position_summary))
  end

  defp parse_number("", _position, summary) do
    summary
  end

  defp report(summary, position, gamma_rate) when map_size(summary) > position do
    {low, high} = Map.get(summary, position)

    new_gamma_rate =
      case low > high do
        true -> gamma_rate <> "0"
        false -> gamma_rate <> "1"
      end

    report(summary, position + 1, new_gamma_rate)
  end

  defp report(summary, _position, gamma_rate) do
    gamma = String.to_integer(gamma_rate, 2)
    bits = map_size(summary)
    epsilon = bxor(gamma, (1 <<< bits) - 1)
    {gamma, epsilon}
  end
end

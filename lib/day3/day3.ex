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

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, {{[], 0}, {[], 0}}, &diagnose_life_support/2)
    |> report_life_support()
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

  defp diagnose_life_support(<<"0", res::binary>>, {{low, low_count}, high}),
    do: {{[res | low], low_count + 1}, high}

  defp diagnose_life_support(<<"1", res::binary>>, {low, {high, high_count}}),
    do: {low, {[res | high], high_count + 1}}

  defp diagnose_life_support("", acc), do: acc

  defp report_bit_life_support_rating({{low, low_count}, {high, high_count}})
       when low_count > high_count do
    {{"0", low}, {"1", high}}
  end

  defp report_bit_life_support_rating({{low, _low_count}, {high, _high_count}}) do
    {{"1", high}, {"0", low}}
  end

  defp scan_life_support([number | tail], bit_length, type, {acc, gas_rating, _}) do
    scan_life_support(
      tail,
      bit_length,
      type,
      {diagnose_life_support(number, acc), gas_rating, number}
    )
  end

  defp scan_life_support([], bit_length, type, {acc, gas_rating, last}) do
    report = report_bit_life_support_rating(acc)

    {bit_gas, gas_set} =
      case type do
        :o2 -> elem(report, 0)
        :co2 -> elem(report, 1)
      end

    case gas_set do
      [] when byte_size(gas_rating) < bit_length ->
        gas_rating <> last

      [] ->
        gas_rating

      _ ->
        scan_life_support(
          gas_set,
          bit_length,
          type,
          {{{[], 0}, {[], 0}}, gas_rating <> bit_gas, last}
        )
    end
  end

  defp report_life_support(first_scan) do
    {{o2, [n | _] = o2_set}, {co2, co2_set}} = report_bit_life_support_rating(first_scan)
    bit_length = String.length(n) + 1
    IO.inspect(bit_length)

    o2_result =
      scan_life_support(o2_set, bit_length, :o2, {{{[], 0}, {[], 0}}, o2, ""})
      |> String.to_integer(2)

    co2_result =
      scan_life_support(co2_set, bit_length, :co2, {{{[], 0}, {[], 0}}, co2, ""})
      |> String.to_integer(2)

    o2_result * co2_result
  end
end

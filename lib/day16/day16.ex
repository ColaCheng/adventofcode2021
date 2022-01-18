defmodule Day16 do
  @input_file "./lib/day16/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, "", &process/2)
    |> decode_packet()
    |> elem(0)
    |> version_sum(0)
  end

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, "", &process/2)
    |> decode_packet()
    |> elem(0)
    |> eval_packet()
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp convert(raw) do
    String.split(raw, "\n", trim: true)
    |> hd()
  end

  defp process(data, acc) do
    to_bits(data, acc)
  end

  defp to_bits("", acc), do: acc

  defp to_bits(<<h::binary-size(1), rest::binary>>, acc) do
    to_bits(rest, <<acc::bits, String.to_integer(h, 16)::4>>)
  end

  defp decode_packet(bin) do
    case bin do
      <<version::3, type::3, rest::bits>> ->
        case type do
          4 ->
            {literal, rest} = decode_literal_packet(rest)
            {{version, :literal, literal}, rest}

          _ ->
            {packets, rest} = decode_operator_packet(rest)
            {{version, type, packets}, rest}
        end

      _ ->
        {nil, bin}
    end
  end

  defp decode_literal_packet(bits, acc \\ 0) do
    <<more::1, n::4, rest::bits>> = bits
    acc = acc * 16 + n

    case more do
      1 -> decode_literal_packet(rest, acc)
      0 -> {acc, rest}
    end
  end

  defp decode_operator_packet(bits) do
    case bits do
      <<0::1, total_size::15, rest::bits>> ->
        <<packets::bitstring-size(total_size), rest::bits>> = rest
        {packets, <<>>} = decode_packets(packets, [])
        {packets, rest}

      <<1::1, num_packets::11, rest::bits>> ->
        decode_n_packets(rest, num_packets, [])
    end
  end

  defp decode_packets(bits, acc) do
    case decode_packet(bits) do
      {nil, rest} ->
        {Enum.reverse(acc), rest}

      {packet, rest} ->
        decode_packets(rest, [packet | acc])
    end
  end

  defp decode_n_packets(bits, 0, acc), do: {Enum.reverse(acc), bits}

  defp decode_n_packets(bits, num_packets, acc) do
    {packet, rest} = decode_packet(bits)
    decode_n_packets(rest, num_packets - 1, [packet | acc])
  end

  defp version_sum({version, :literal, _}, acc) do
    version + acc
  end

  defp version_sum({version, _, packets}, acc) do
    Enum.reduce(packets, version + acc, &version_sum/2)
  end

  defp eval_packet({_, :literal, value}), do: value

  defp eval_packet({_, type, args}) do
    args = Enum.map(args, &eval_packet/1)

    case type do
      0 ->
        Enum.sum(args)

      1 ->
        Enum.reduce(args, 1, &*/2)

      2 ->
        Enum.min(args)

      3 ->
        Enum.max(args)

      5 ->
        [first, second] = args
        (first > second && 1) || 0

      6 ->
        [first, second] = args
        (first < second && 1) || 0

      7 ->
        [first, second] = args
        (first == second && 1) || 0
    end
  end
end

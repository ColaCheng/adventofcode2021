defmodule Day10 do
  @input_file "./lib/day10/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, [], &process/2)
    |> Enum.reduce([], fn
      {[expect], _}, acc -> [expect | acc]
      _, acc -> acc
    end)
    |> Enum.frequencies()
    |> Enum.reduce(0, fn {k, v}, acc ->
      point(k) * v + acc
    end)
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

  defp process(lines, acc) do
    [diagnostic(lines, {[], []}) | acc]
  end

  defp diagnostic(<<chunk::binary-size(1), rest::binary>>, {errors, []}) do
    diagnostic(rest, {errors, [chunk]})
  end

  defp diagnostic(<<chunk::binary-size(1), rest::binary>>, {errors, [last_chunk | tail] = acc}) do
    case expect(chunk) do
      nil -> diagnostic(rest, {errors, [chunk | acc]})
      ^last_chunk -> diagnostic(rest, {errors, tail})
      _ -> diagnostic(rest, {[chunk | errors], tail})
    end
  end

  defp diagnostic("", acc), do: acc

  defp expect(")"), do: "("
  defp expect("]"), do: "["
  defp expect("}"), do: "{"
  defp expect(">"), do: "<"
  defp expect(_), do: nil

  defp point(")"), do: 3
  defp point("]"), do: 57
  defp point("}"), do: 1197
  defp point(">"), do: 25137
end

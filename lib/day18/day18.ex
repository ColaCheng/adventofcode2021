defmodule Day18 do
  @input_file "./lib/day18/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, [], &process/2)
    |> Enum.reverse()
    |> Enum.reduce(fn
      n, sum ->
        reduce([sum, n])
    end)
    |> magnitude()
  end

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    numbers =
      IO.read(file, :line)
      |> read_line_reduce(file, [], &process/2)
      |> Enum.reverse()

    Enum.reduce(numbers, 0, fn
      n1, highest ->
        Enum.reduce(numbers -- [n1], highest, fn n2, hightest ->
          max(hightest, reduce([n1, n2]) |> magnitude())
        end)
    end)
  end

  def reduce(n) do
    case explode(n) do
      nil ->
        case split(n) do
          {true, n} ->
            reduce(n)

          {false, _} ->
            n
        end

      n ->
        reduce(n)
    end
  end

  def explode(n) do
    case do_explode(n, 0) do
      {_, nil, nil} ->
        nil

      {exploded, _, _} ->
        exploded
    end
  end

  defp do_explode([a, b], 4), do: {0, [a], [b]}

  defp do_explode([a, b], level) do
    {a, left, right} = do_explode(a, level + 1)
    {b, right} = propagate(:right, right, b)

    case {left, right} do
      {nil, nil} ->
        {b, left, right} = do_explode(b, level + 1)
        {a, left} = propagate(:left, left, a)
        {[a, b], left, right}

      _ ->
        {[a, b], left, right}
    end
  end

  defp do_explode(n, _) when is_integer(n), do: {n, nil, nil}

  defp propagate(_, nil, a), do: {a, nil}
  defp propagate(_, [], a), do: {a, []}

  defp propagate(_, [n], a) when is_integer(a) do
    {n + a, []}
  end

  defp propagate(:left, [n], [a, b]) do
    {b, []} = propagate(:left, [n], b)
    {[a, b], []}
  end

  defp propagate(:right, [n], [a, b]) do
    {a, []} = propagate(:right, [n], a)
    {[a, b], []}
  end

  defp split([a, b]) do
    case split(a) do
      {false, a} ->
        case split(b) do
          {false, b} ->
            {false, [a, b]}

          {true, b} ->
            {true, [a, b]}
        end

      {true, a} ->
        {true, [a, b]}
    end
  end

  defp split(n) when is_integer(n) and n > 9, do: {true, split_number(n)}
  defp split(other), do: {false, other}

  defp split_number(n) do
    q = n / 2
    [floor(q), ceil(q)]
  end

  defp magnitude([a, b]) do
    magnitude(a) * 3 + magnitude(b) * 2
  end

  defp magnitude(n) when is_integer(n), do: n

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

  defp process(data, acc) do
    [parse(data, []) | acc]
  end

  defp parse("", acc), do: Enum.reverse(acc) |> hd()

  defp parse("[" <> rest, acc) do
    parse(rest, acc)
  end

  defp parse("]" <> rest, [h1, h2 | acc]) do
    parse(rest, [[h2, h1] | acc])
  end

  defp parse("," <> rest, acc) do
    parse(rest, acc)
  end

  defp parse(<<n::binary-size(1), rest::binary>>, acc) do
    parse(rest, [String.to_integer(n) | acc])
  end
end

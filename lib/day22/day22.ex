defmodule Day22 do
  @input_file "./lib/day22/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, [], &process/2)
    |> Enum.reject(fn {_, {xr, yr, zr}} ->
      Enum.any?([xr, yr, zr], fn r ->
        r.first < -50 || r.last > 50
      end)
    end)
    |> solve()
  end

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, [], &process/2)
    |> solve()
  end

  defp solve(ops) do
    cuboids = []

    Enum.reduce(ops, cuboids, &execute/2)
    |> Enum.reduce(0, fn {xr, yr, zr}, count ->
      count + range_size(xr) * range_size(yr) * range_size(zr)
    end)
  end

  defp execute({action, new_cuboid}, cuboids) do
    cuboids =
      Enum.flat_map(cuboids, fn old_cuboid ->
        if overlap?(old_cuboid, new_cuboid) do
          split_cuboid(old_cuboid, new_cuboid)
          |> Enum.reject(fn cuboid ->
            overlap?(cuboid, new_cuboid)
          end)
        else
          [old_cuboid]
        end
      end)

    case action do
      :on ->
        [new_cuboid | cuboids]

      :off ->
        cuboids
    end
  end

  defp split_cuboid(cuboid, reference) do
    split_cuboids([cuboid], reference, 0)
  end

  defp split_cuboids(cuboids, _reference, 3), do: cuboids

  defp split_cuboids(cuboids, reference, axis) do
    new_cuboids = Enum.flat_map(cuboids, &split_one(&1, reference, axis))
    split_cuboids(new_cuboids, reference, axis + 1)
  end

  defp split_one(cuboid, reference, axis) do
    cr = elem(cuboid, axis)
    rr = elem(reference, axis)

    [
      cr.first..(rr.first - 1),
      max(cr.first, rr.first)..min(cr.last, rr.last),
      (min(cr.last, rr.last) + 1)..cr.last
    ]
    |> Enum.reject(&(range_size(&1, 1) === 0))
    |> Enum.map(fn r ->
      put_elem(cuboid, axis, r)
    end)
  end

  defp range_size(%{__struct__: Range, first: first, last: last} = range) do
    step = if first <= last, do: 1, else: -1
    range_size(range, step)
  end

  defp range_size(first..last, step) when step > 0 and first > last, do: 0
  defp range_size(first..last, step) when step < 0 and first < last, do: 0
  defp range_size(first..last, step), do: abs(div(last - first, step)) + 1

  defp overlap?({xr1, yr1, zr1}, {xr2, yr2, zr2}) do
    not (Range.disjoint?(xr1, xr2) or
           Range.disjoint?(yr1, yr2) or
           Range.disjoint?(zr1, zr2))
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    Enum.reverse(acc)
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp convert(raw) do
    String.trim(raw)
  end

  defp process(data, acc) do
    {on_off, rest} =
      case data do
        "on " <> rest ->
          {:on, rest}

        "off " <> rest ->
          {:off, rest}
      end

    range =
      String.split(rest, ",")
      |> Enum.map(fn <<_, "=", rest::binary>> ->
        [from, to] =
          String.split(rest, "..")
          |> Enum.map(&String.to_integer/1)

        from..to
      end)
      |> List.to_tuple()

    [{on_off, range} | acc]
  end
end

defmodule Day17 do
  @input_file "./lib/day17/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    {_, {y1, _y2}} =
      IO.read(file, :all)
      |> parse()

    max_vy = abs(y1) - 1

    div((max_vy + 1) * max_vy, 2)
  end

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :all)
    |> parse()
    |> count()
  end

  defp count({{x1, x2}, {y1, y2}}) do
    for vx <- 1..x2, vy <- y1..(1 - y1) do
      simulate(0, 0, vx, vy, x1, x2, y1, y2)
    end
    |> Enum.count(&(&1 == :in))
  end

  defp simulate(x, y, _vx, _vy, x1, x2, y1, y2) when x in x1..x2 and y in y1..y2, do: :in
  defp simulate(x, y, _vx, _vy, _x1, x2, y1, _y2) when x > x2 or y < y1, do: :out

  defp simulate(x, y, vx, vy, x1, x2, y1, y2),
    do: simulate(x + vx, y + vy, update(vx), vy - 1, x1, x2, y1, y2)

  defp update(0), do: 0
  defp update(vx), do: vx + ((vx < 0 && 1) || -1)

  defp parse(raw) do
    String.split(raw, ["target area: ", ", ", "\n"], trim: true)
    |> Enum.reduce({nil, nil}, fn
      "x=" <> rest, {_, y} ->
        [x1, x2] =
          String.split(rest, "..")
          |> Enum.map(&String.to_integer/1)

        {{x1, x2}, y}

      "y=" <> rest, {x, _} ->
        [y1, y2] =
          String.split(rest, "..")
          |> Enum.map(&String.to_integer/1)

        {x, {y1, y2}}
    end)
  end
end

defmodule Day20 do
  @input_file "./lib/day20/input"

  def run1(steps \\ 2) do
    {:ok, file} = File.open(@input_file, [:read])

    [enhance, image] =
      IO.read(file, :all)
      |> String.split("\n\n", trim: true)

    enhance = parse_enhance(enhance)
    image = parse_image(image)

    apply_enhance({image, 0}, enhance, steps)
    |> elem(0)
    |> Enum.count(&(elem(&1, 1) == 1))
  end

  def run2(), do: run1(50)

  defp apply_enhance(image, _enhance, 0), do: image

  defp apply_enhance({image, default}, enhance, steps) do
    image = expand(image, default)

    image =
      Enum.map(image, fn {pos, _} ->
        algo_key =
          Enum.reduce(neighbors(pos), 0, fn k, acc ->
            acc * 2 + Map.get(image, k, default)
          end)

        {pos, Map.fetch!(enhance, algo_key)}
      end)
      |> Map.new()

    default = Map.fetch!(enhance, default)
    apply_enhance({image, default}, enhance, steps - 1)
  end

  defp expand(image, default) do
    Enum.reduce(image, image, fn {pos, _}, acc ->
      neighbors = neighbors(pos)

      Enum.reduce(neighbors, acc, fn pos, acc ->
        case Map.has_key?(acc, pos) do
          true -> acc
          false -> Map.put(acc, pos, default)
        end
      end)
    end)
  end

  defp neighbors({x, y}) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
  end

  defp parse_enhance(raw) do
    512 = String.length(raw)

    String.codepoints(raw)
    |> Enum.reduce(
      {[], 0},
      fn
        "#", {acc, index} -> {[{index, 1} | acc], index + 1}
        ".", {acc, index} -> {[{index, 0} | acc], index + 1}
      end
    )
    |> elem(0)
    |> Map.new()
  end

  defp parse_image(raw) do
    String.split(raw, "\n", trim: true)
    |> Enum.reduce({[], 0}, fn e, {acc, y} ->
      {acc, _} =
        String.codepoints(e)
        |> Enum.reduce({acc, 0}, fn e, {acc, x} ->
          v =
            case e do
              "#" -> 1
              "." -> 0
            end

          {[{{x, y}, v} | acc], x + 1}
        end)

      {acc, y + 1}
    end)
    |> elem(0)
    |> Map.new()
  end
end

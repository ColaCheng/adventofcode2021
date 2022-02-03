defmodule Day24 do
  @input_file "./lib/day24/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, [], &parse/2)
    |> solve(&>/2)
  end

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, [], &parse/2)
    |> solve(&</2)
  end

  def solve(input, better?) do
    decompile(input)
    |> Enum.reduce(Map.new([{0, 0}]), fn {kind, parameter}, acc ->
      Enum.reduce(acc, %{}, fn {z, digits}, acc ->
        range =
          if kind === :maybe_pop do
            # This operation can either push or pop depending on
            # the digit. Discard digits that will push, because those
            # will never become zero in the end.
            Enum.filter(1..9, fn digit ->
              rem(z, 26) + parameter === digit
            end)
          else
            1..9
          end

        Enum.reduce(range, acc, fn digit, acc ->
          z =
            case kind do
              :maybe_pop ->
                div(z, 26)

              :push ->
                26 * z + parameter + digit
            end

          new_digit = digits * 10 + digit

          case acc do
            %{^z => other_digit} ->
              cond do
                better?.(other_digit, new_digit) ->
                  acc

                z ->
                  Map.put(acc, z, new_digit)

                true ->
                  acc
              end

            %{} ->
              Map.put(acc, z, new_digit)
          end
        end)
      end)
    end)
    |> Enum.find_value(fn {z, digits} ->
      z === 0 && digits
    end)
  end

  defp decompile([
         {:inp, :w},
         {:mul, :x, 0},
         {:add, :x, :z},
         {:mod, :x, 26},
         {:div, :z, par_a},
         {:add, :x, par_b},
         {:eql, :x, :w},
         {:eql, :x, 0},
         {:mul, :y, 0},
         {:add, :y, 25},
         {:mul, :y, :x},
         {:add, :y, 1},
         {:mul, :z, :y},
         {:mul, :y, 0},
         {:add, :y, :w},
         {:add, :y, par_c},
         {:mul, :y, :x},
         {:add, :z, :y} | is
       ]) do
    # The numbers are used as a kind of stack, pushing by multiplying
    # with 26 and popping by dividing by 26.
    f =
      if par_b < 10 do
        ^par_a = 26
        {:maybe_pop, par_b}
      else
        ^par_a = 1
        {:push, par_c}
      end

    [f | decompile(is)]
  end

  defp decompile([]), do: []

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    Enum.reverse(acc)
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(raw, acc), reducer)
  end

  defp parse(cmd, acc) do
    cmd =
      String.split(cmd, [" ", "\n"], trim: true)
      |> Enum.map(fn e ->
        case Integer.parse(e) do
          :error ->
            String.to_atom(e)

          {n, _} ->
            n
        end
      end)
      |> List.to_tuple()

    [cmd | acc]
  end
end

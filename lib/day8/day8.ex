defmodule Day8 do
  @input_file "./lib/day8/input"

  def run1() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, %{}, &process/2)
    |> Enum.reduce(0, &(elem(&1, 1) + &2))
  end

  def run2() do
    {:ok, file} = File.open(@input_file, [:read])

    IO.read(file, :line)
    |> read_line_reduce(file, [], &process2/2)
    |> Enum.sum()
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp convert(raw) do
    [signals, outputs] =
      raw
      |> String.split(" | ", trim: true)
      |> Enum.map(&String.split(&1, [" ", "\n"], trim: true))

    {signals, outputs}
  end

  defp process({_signals, outputs}, acc) do
    Enum.reduce(outputs, acc, fn digits, acc ->
      case determine_number(digits) do
        nil -> acc
        number -> Map.update(acc, number, 1, &(&1 + 1))
      end
    end)
  end

  defp determine_number(digits) when byte_size(digits) == 2, do: 1
  defp determine_number(digits) when byte_size(digits) == 3, do: 7
  defp determine_number(digits) when byte_size(digits) == 4, do: 4
  defp determine_number(digits) when byte_size(digits) == 7, do: 8
  defp determine_number(_digits), do: nil

  defp process2({signals, outputs}, acc) do
    %{2 => [one], 3 => [seven], 4 => [four], 5 => len_five, 6 => len_six, 7 => [eight]} =
      Enum.group_by(signals, &byte_size/1, &(String.to_charlist(&1) |> Enum.sort()))

    {[nine], left_len_six} = Enum.split_with(len_six, fn e -> four -- e == [] end)
    {[zero], [six]} = Enum.split_with(left_len_six, fn e -> one -- e == [] end)
    {[three], left_len_five} = Enum.split_with(len_five, fn e -> one -- e == [] end)
    {[five], [two]} = Enum.split_with(left_len_five, fn e -> length(six -- e) == 1 end)

    digit_map = %{
      zero => ?0,
      one => ?1,
      two => ?2,
      three => ?3,
      four => ?4,
      five => ?5,
      six => ?6,
      seven => ?7,
      eight => ?8,
      nine => ?9
    }

    [
      Enum.map(outputs, fn e ->
        digits = String.to_charlist(e) |> Enum.sort()
        Map.get(digit_map, digits)
      end)
      |> List.to_integer()
      | acc
    ]
  end
end

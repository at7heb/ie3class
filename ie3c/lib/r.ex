defmodule R do
  alias Ie3c.Transactions.Transactions
  # alias Ie3C.Transactions.Transaction

  def r, do: r("/Users/howard/Documents/dev/ie3class/ie3c/priv/static/2022-all.csv")

  def r(filename) do
    # a = Transactions.load_all()
    _stt =
      %{xs: Transactions.make(Transactions.load_all(filename))}
      |> Map.put(:items, [])
      |> Transactions.get_interest()
      |> Transactions.get_checks()
      |> Transactions.get_concur()
      |> Transactions.get_paypals()
      |> Transactions.get_ach_xfers()

    # IO.puts("File #{filename}")
    # categorized = lengt(Enum.filter(stt.xs, fn elt -> elt.categorized end))
    # total = length(stt.xs)
    # IO.puts("#{total} transactions, #{categorized} categorized")
  end

  def all do
    months = ~w/01 02 03 04 05 06 07 08 09 10 11 12/

    Enum.map(months, fn m ->
      # (IO.puts("--------------------------- #{m} ---------------------------")
      stt = r("/Users/howard/Documents/dev/ie3class/ie3c/priv/static/2022-#{m}.csv")
      output_items(stt, m)
      output_uncategorized(stt, m)
      []
    end)

    nil
  end

  def output_items(%{items: items} = _stt, m) do
    items_map_list = Enum.map(items, fn elt -> Map.from_struct(elt) end)

    cond do
      length(items_map_list) == 0 ->
        nil

      true ->
        write_csv(
          [
            strings(Map.keys(Enum.at(items_map_list, 0)))
            | dollars(Enum.map(items_map_list, fn elt -> Map.values(elt) end))
          ],
          "items",
          m
        )
    end
  end

  def strings(header_list), do: Enum.map(header_list, fn t -> Atom.to_string(t) end)

  def dollars(things), do: Enum.map(things, fn elt -> dollars1(elt) end)

  def dollars1(l0) do
    l1 =
      cond do
        Enum.fetch!(l0, 1) == 0 -> l0
        true -> List.replace_at(l0, 1, Enum.fetch!(l0, 1) / 100)
      end

    cond do
      Enum.fetch!(l1, 2) == 0 -> l1
      true -> List.replace_at(l1, 2, Enum.fetch!(l1, 2) / 100)
    end
  end

  def output_uncategorized(%{xs: xss} = _stt, m) do
    xns_map_list =
      Enum.filter(xss, fn elt -> not elt.categorized end)
      |> Enum.map(fn elt -> Map.from_struct(elt) end)

    cond do
      length(xns_map_list) == 0 ->
        nil

      true ->
        write_csv(
          [
            strings(Map.keys(Enum.at(xns_map_list, 0)))
            | Enum.map(xns_map_list, fn elt -> Map.values(elt) end)
          ],
          "ncat",
          m
        )
    end

    []
  end

  def write_csv(l, tag, id) do
    filename = "/Users/howard/Documents/dev/ie3class/ie3c/priv/static/#{tag}-2022-#{id}.csv"

    CSV.encode(l, separator: ?,, delimiter: "\n")
    |> Stream.into(File.stream!(filename, [:write, :utf8]))
    |> Stream.run()

    [1]
  end
end

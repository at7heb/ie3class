defmodule R do
  alias Ie3c.Transactions.Transactions
  # alias Ie3C.Transactions.Transaction

  def r, do: r("/Users/howard/Documents/dev/ie3class/ie3c/priv/static/2022-all.csv")
  def r(filename) do
    # a = Transactions.load_all()
    stt = (
      %{xs: Transactions.make(Transactions.load_all(filename))}
      |> Map.put(:items, [])
      |> Transactions.get_interest()
      |> Transactions.get_checks()
      |> Transactions.get_concur()
      |> Transactions.get_paypals()
    )
    IO.inspect(stt.items, label: "Items")
    categorized = Enum.reduce(stt.xs, 0, fn elt, count -> count + (if elt.categorized do 1 else 0 end) end)
    total = length(stt.xs)
    IO.puts("#{total} transactions, #{categorized} categorized")
    Enum.filter(stt.xs, fn elt -> elt.categorized == false end)
    |> IO.inspect(label: "uncategorized")
  end

  def all do
    months = ~w/01 02 03 04 05 06 07 08 09 10 11 12/
    Enum.map(months, fn m ->
      (IO.puts("--------------------------- #{m} ---------------------------")
      r("/Users/howard/Documents/dev/ie3class/ie3c/priv/static/2022-#{m}.csv"))
    end)
    nil
  end
end

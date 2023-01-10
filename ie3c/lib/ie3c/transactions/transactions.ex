defmodule Ie3c.Transactions.Transactions do

  def load_all do
    headers = [:account, :date, :amount, :currency,
    :category, :type, :task, :code, :pref, :cref,
    :bookkey, :exported, :export_date, :exporter_id]
    "/Users/howard/Documents/dev/ie3class/ie3c/priv/static/2022-all.csv"
     |> Path.expand()
     |> File.stream!
     |> Enum.slice(1..-1//1)
     |> CSV.decode!(separator: ?,, headers: headers)
     |> Enum.sort(fn a, b -> a.date <= b.date end)
  end

  def make(a) when is_list(a) do
    Enum.map(a, fn elt -> struct(Ie3c.Transactions.Transaction, elt) end)
  end

  @spec get_interest(%{:items => list, :xs => any, optional(any) => any}) :: %{
          :items => list,
          :xs => any,
          optional(any) => any
        }
  def get_interest(%{xs: xss, items: items} = stt) do
    l = Enum.filter(xss, fn elt -> elt.category == "Interest Paid" end)
    new_items = (
      Enum.map(l, fn elt -> %{ref: "Interest", income: elt.amount, date: elt.date} end)
      |> Enum.map(fn elt -> struct(Ie3c.Transactions.Item, elt) end)
    )
    %{stt | items: items ++ new_items}
  end

  def get_checks(%{xs: xss, items: items} = stt) do
    l = Enum.filter(xss, fn elt -> String.contains?(elt.pref, "CHECK PAIDWIL") end)
    new_items = (
      Enum.map(l, fn elt -> %{ref: "Check " <> elt.cref, expense: elt.amount, date: elt.date} end)
      |> Enum.map(fn elt -> struct(Ie3c.Transactions.Item, elt) end)
    )
    %{stt | items: items ++ new_items}
  end

  def get_concur(%{xs: xss, items: items} = stt) do
    l = Enum.filter(xss, fn elt -> elt.category == "Concur Activity" end)
    new_items = (
      Enum.map(l, fn elt -> %{ref: "Concur " <> elt.type, expense: elt.amount, date: elt.date, task: elt.task} end)
      |> Enum.map(fn elt -> struct(Ie3c.Transactions.Item, elt) end)
    )
    %{stt | items: items ++ new_items}
  end
end

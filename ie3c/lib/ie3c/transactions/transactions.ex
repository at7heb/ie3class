defmodule Ie3c.Transactions.Transactions do
  import CSV
  def load_all do
    headers = [:account, :date, :amount, :currency,
    :category, :type, :task, :code, :pref, :cref,
    :bookkey, :exported, :export_date, :exporter_id]
    "/Users/howard/Documents/dev/ie3class/ie3c/priv/static/2022-all.csv"
     |> Path.expand() |> IO.inspect(label: "path1")
     |> File.stream!
     |> Enum.slice(1..-1//1)
     |> CSV.decode!(separator: ?,, headers: headers)
     |> Enum.sort(fn a, b -> a.date <= b.date end) 
  end

  def make(a) when is_list(a) do
    Enum.map(a, fn elt -> struct(Ie3c.Transactions.Transaction, elt) end)
  end
end

defmodule R do
  alias Ie3c.Transactions.Transactions
  # alias Ie3C.Transactions.Transaction

  def r do
    # a = Transactions.load_all()
    stt = (
      %{xs: Transactions.make(Transactions.load_all())}
      |> Map.put(:items, [])
      |> Transactions.get_interest()
      |> Transactions.get_checks()
      |> Transactions.get_concur()
      |> Transactions.get_paypals()
    )
    IO.inspect(stt.items, label: "Items")
    categorized = Enum.reduce(stt.xs, 0, fn elt, count -> count + (if elt.categorized do 1 else 0 end) end)
    total = length(stt.xs)
    IO.puts("#{total} items, #{categorized} categorized")
  end
end

defmodule R do
  alias Ie3c.Transactions.Transactions
  alias Ie3C.Transactions.Transaction

  def r do
    # a = Transactions.load_all()
    stt = (
      %{xs: Transactions.make(Transactions.load_all())}
      |> Map.put(items: [])
      |> Transactions.get_interest()
    )
    IO.inspect(stt.items, label: "Items")
  end
end

defmodule Ie3c.Transactions.Transaction do
  #Account,Value Date,Amount,Ccy.,Category,Expense/Revenue Type,
  #Task,Transaction Code,Payment Reference,Customer Reference,
  #Booking Key,Exported,Export Date,Export User

  defstruct account: "", date: ~N[2020-01-01 00:00:00], amount: 0.00, currency: "USD",
    category: "", type: "", task: "", code: "", pref: "", cref: 0,
    bookkey: 0, exported: 0, export_date: ~N[2020-01-01 12:00:00], exporter_id: 0,
    categorized: false
end

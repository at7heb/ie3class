defmodule Ie3c.Transactions.Transaction do
  # Account,Value Date,Amount,Ccy.,Category,Expense/Revenue Type,
  # Task,Transaction Code,Payment Reference,Customer Reference,
  # Booking Key,Exported,Export Date,Export User

  defstruct account: "",
            date: ~D[2020-01-01],
            amount: 0,
            currency: "USD",
            category: "",
            type: "",
            task: "",
            code: "",
            pref: "",
            cref: 0,
            bookkey: 0,
            exported: 0,
            export_date: ~D[2020-01-01],
            exporter_id: 0,
            categorized: false
end

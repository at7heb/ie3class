defmodule Ie3c.Transactions.Item do
  defstruct ref: "", date: ~D[2020-01-01], income: 0, expense: 0, task: ""

  def make_numeric(item_list) when is_list(item_list) do
    Enum.map(item_list, fn i -> make_numeric(i) end)
  end
  def make_numeric(%Ie3c.Transactions.Item{income: 0, expense: 0} = i), do: i
  def make_numeric(%Ie3c.Transactions.Item{income: 0, expense: expense} = i), do: %{i|expense: make_numeric(expense)}
  def make_numeric(%Ie3c.Transactions.Item{income: income, expense: 0} = i), do: %{i|income: make_numeric(income)}
  def make_numeric(%Ie3c.Transactions.Item{income: income, expense: expense} = i), do:
      %{i|income: make_numeric(income), expense: make_numeric(expense)}
  def make_numeric(s) when is_binary(s) do
    String.replace(s, ["-", "."], "")
    |> String.to_integer()
  end

end

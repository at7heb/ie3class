defmodule Ie3c.Transactions.Transactions do
  alias Ie3c.Transactions.Transaction
  alias Ie3c.Transactions.Item

  def load_all(file) do
    headers = [
      :account,
      :date,
      :amount,
      :currency,
      :category,
      :type,
      :task,
      :code,
      :pref,
      :cref,
      :bookkey,
      :exported,
      :export_date,
      :exporter_id
    ]

    file
    |> Path.expand()
    |> File.stream!()
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

    new_items =
      Enum.map(l, fn elt -> %{ref: "Interest", income: elt.amount, date: elt.date} end)
      |> Enum.map(fn elt -> struct(Ie3c.Transactions.Item, elt) end)

    %{stt | items: items ++ Item.make_numeric(new_items)}
    |> update_categorized(l)
  end

  def get_ach_xfers(%{xs: xss, items: items} = stt) do
    l = Enum.filter(xss, fn elt -> String.contains?(elt.category, "Miscellaneous ACH Debit") end)

    new_items =
      Enum.map(l, fn elt ->
        %{
          ref: "#{elt.pref} #{elt.type}",
          income: maybe_income(elt.amount),
          expense: maybe_expense(elt.amount),
          date: elt.date
        }
      end)
      |> Enum.map(fn elt -> struct(Ie3c.Transactions.Item, elt) end)

    %{stt | items: items ++ Item.make_numeric(new_items)}
    |> update_categorized(l)
  end

  def get_rebates(%{xs: xss, items: items} = stt) do
    l = Enum.filter(xss, fn elt -> String.contains?(elt.pref, "REBATE") end)

    new_items =
      Enum.map(l, fn elt ->
        %{
          ref: "#{elt.pref} (#{elt.category})",
          income: elt.amount,
          date: elt.date
        }
      end)
      |> Enum.map(fn elt -> struct(Ie3c.Transactions.Item, elt) end)

    %{stt | items: items ++ Item.make_numeric(new_items)}
    |> update_categorized(l)
  end

  def get_mail_deposits(%{xs: xss, items: items} = stt) do
    l = Enum.filter(xss, fn elt -> String.contains?(elt.pref, "BANK BY MAIL DEPOSIT") end)

    new_items =
      Enum.map(l, fn elt ->
        %{
          ref: "#{elt.pref}",
          income: elt.amount,
          date: elt.date
        }
      end)
      |> Enum.map(fn elt -> struct(Ie3c.Transactions.Item, elt) end)

    %{stt | items: items ++ Item.make_numeric(new_items)}
    |> update_categorized(l)
  end

  def get_checks(%{xs: xss, items: items} = stt) do
    l = Enum.filter(xss, fn elt -> String.contains?(elt.pref, "CHECK PAIDWIL") end)

    new_items =
      Enum.map(l, fn elt -> %{ref: "Check " <> elt.cref, expense: elt.amount, date: elt.date} end)
      |> Enum.map(fn elt -> struct(Ie3c.Transactions.Item, elt) end)

    %{stt | items: items ++ Item.make_numeric(new_items)}
    |> update_categorized(l)
  end

  def get_concur(%{xs: xss, items: items} = stt) do
    # expense concur items
    l = Enum.filter(xss, fn elt -> elt.category == "Concur Activity" end)

    refs =
      Enum.map(l, fn elt -> elt.pref end)
      |> Enum.uniq()

    new_items = Enum.map(refs, fn ref -> make_concur_item(ref, l) end)

    %{stt | items: items ++ new_items}
    |> update_categorized(l)
  end

  def make_concur_item(ref, item_list) do
    items = Enum.filter(item_list, fn elt -> ref == elt.pref end)

    income =
      Enum.filter(items, fn elt -> not String.starts_with?(elt.amount, "-") end)
      |> Enum.map(fn elt -> elt.amount end)
      |> Enum.map(fn elt -> Item.make_numeric(elt) end)
      |> Enum.sum()

    expense =
      Enum.filter(items, fn elt -> String.starts_with?(elt.amount, "-") end)
      |> Enum.map(fn elt -> elt.amount end)
      |> Enum.map(fn elt -> Item.make_numeric(elt) end)
      |> Enum.sum()

    date =
      Enum.map(items, fn elt -> elt.date end)
      |> Enum.sort()
      |> Enum.at(0)

    type =
      Enum.map(items, fn elt -> elt.type end)
      |> Enum.at(0)

    struct(
      Item,
      %{ref: "concur #{type} #{ref}", date: date, income: income, expense: expense, task: ""}
    )
  end

  def get_paypals(%{xs: xss} = stt) do
    l = Enum.filter(xss, fn elt -> elt.category == "Paypal Activity" end)

    l
    |> get_meetings()
    |> handle_the_meetings(stt)
    |> update_categorized(l)
  end

  def handle_the_meetings(meeting_list, %{xs: _xss, items: _items} = stt) do
    Enum.reduce(meeting_list, stt, fn meeting, state -> handle_a_meeting(meeting, state) end)
  end

  def handle_a_meeting(meeting, %{xs: xss, items: items} = stt) do
    meeting_items =
      Enum.filter(xss, fn elt -> String.contains?(elt.pref, "-Meeting \##{meeting}:") end)
      |> Enum.map(fn elt -> make_a_meeting_item(elt) end)
      |> Item.make_numeric()

    income = Enum.reduce(meeting_items, 0, fn item, acc -> acc + item.income end)
    expense = Enum.reduce(meeting_items, 0, fn item, acc -> acc + item.expense end)
    date = Map.fetch!(Enum.at(meeting_items, 0), :date)
    ref = get_a_meeting_ref(Enum.at(meeting_items, 0))
    item = %Item{}
    item = %{item | ref: ref, date: date, income: income, expense: expense}
    %{stt | items: items ++ [item]}
  end

  def make_a_meeting_item(%Transaction{amount: amount, date: date, pref: pref} = _xn) do
    income =
      if String.starts_with?(amount, "-") do
        0
      else
        amount
      end

    expense =
      if String.starts_with?(amount, "-") do
        String.slice(amount, 1..-1//1)
      else
        0
      end

    rv = %Item{}
    %{rv | ref: pref, date: date, income: income, expense: expense}
  end

  def get_a_meeting_ref(%Item{ref: ref}) do
    ~r/\#(?<ref>.*) - /
    |> Regex.named_captures(ref)
    |> Map.fetch!("ref")
  end

  def get_meetings(xn_list) do
    meeting_set =
      Enum.filter(xn_list, fn elt -> String.contains?(elt.pref, "-Meeting #") end)
      |> Enum.map(fn elt -> extract_meeting_number(elt) end)
      |> MapSet.new()

    MapSet.to_list(meeting_set)
  end

  def extract_meeting_number(%Transaction{pref: ref} = _xn) do
    ~r/Shopping Cart-Meeting \#(?<num>[\d]{1,99}):/
    |> Regex.named_captures(ref)
    |> Map.fetch!("num")
  end

  def update_categorized(%{xs: xss} = stt, newly_categorized) do
    new_xss = Enum.map(xss, fn xaction -> maybe_mark_categorized(xaction, newly_categorized) end)
    %{stt | xs: new_xss}
  end

  def maybe_mark_categorized(xaction, xaction_list) do
    cond do
      xaction in xaction_list -> %{xaction | categorized: true}
      true -> xaction
    end
  end

  def maybe_income(amt) do
    cond do
      String.starts_with?(amt, "-") -> 0
      true -> amt
    end
  end

  def maybe_expense(amt) do
    cond do
      String.starts_with?(amt, "-") -> amt
      true -> 0
    end
  end
end

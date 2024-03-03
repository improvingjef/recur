defmodule Recur.Days do

  alias Recur.Day
  import Function, only: [identity: 1]

  def in_month(date, func \\ &identity/1) do
    1..Date.days_in_month(date)
    |> Stream.map(& %{date | day: &1})
    |> Stream.filter(func)
  end

  def in_month_for(date, {which, day}, week_start)
    when is_atom(day) do
    in_month_for(date, {which, Day.of_week(day, week_start)}, week_start)
  end

  def in_month_for(date, {which, day}, week_start)
    when is_integer(which) and is_integer(day) and which < 0 do
    found =
    date
    |> in_month_for(day, week_start)
    |> Enum.reverse()
    |> Enum.at(-which-1)

    if is_nil(found), do: [], else: [found]
  end

  def in_month_for(date, {which, day}, week_start)
    when is_integer(which) and is_integer(day) and which > 0 do
    found =
    date
    |> in_month_for(day, week_start)
    |> Enum.at(which-1)

    if is_nil(found), do: [], else: [found]
  end

  def in_month_for(date, day, week_start)
    when is_atom(day) do
    date
    |> in_month(& Day.of_week(&1, week_start) == Day.of_week(day, week_start))
  end

  def in_month_for(date, day, week_start)
    when is_integer(day) do
    date
    |> in_month(& Day.of_week(&1, week_start) == day)
  end


  def in_year(date, func \\ &identity/1) do
    %{date | month: 1, day: 1}
    |> Stream.unfold(fn d -> {d, Date.add(d, 1)} end)
    |> Stream.take_while(& Date.compare(&1, %{date | year: date.year + 1}) == :lt)
    |> Stream.filter(func)
  end

  def in_year_for(date, {which, day}, week_start)
    when is_atom(day) do
    in_year_for(date, {which, Day.of_week(day, week_start)}, week_start)
  end

  def in_year_for(date, {which, day}, week_start)
    when is_integer(day) and which > 0 do
    found = date
    |> in_year(& Day.of_week(&1, week_start) == day)
    |> Enum.at(which-1)
    if is_nil(found), do: [], else: [found]
  end

  def in_year_for(date, {which, day}, week_start)
    when is_integer(day) and which < 0 do
    found =
    date
    |> in_year(& Day.of_week(&1, week_start) == day)
    |> Enum.reverse()
    |> Enum.at(-which-1)
    if is_nil(found), do: [], else: [found]
  end
end

defmodule Recur.Week do
  alias Recur.Day

  def of_year(date, week_start) do
    jan1 = %{date | month: 1, day: 1}
    jan1_dow = Day.of_week(jan1, week_start)
    days =
      cond do
        jan1_dow < 5 -> (day_of_year(date) + 1)
        date.month == 1 and date.day <= (8 - jan1_dow) -> date.day + 1 + day_of_year(%{date | year: date.year - 1, month: 12, day: 31})
        true -> (day_of_year(date) + 1 - (8 - jan1_dow))
      end

    (days / 7.0 ) |> Float.ceil(0) |> round()
  end

  def day_of_year(date) do
    jan1 = %{date | month: 1, day: 1}
    case date.month do
      1 -> date.day
      _ ->
        1..(date.month-1)
        |> Enum.map(&(%{ date | month: &1, day: 1}))
        |> Enum.map(&(Date.days_in_month(&1)))
        |> Enum.concat([date.day])
        |> Enum.sum()
    end
  end

  def days_in_year(date, func \\ &identity/1) do
    %{date | month: 1, day: 1}
    |> Stream.unfold(fn d -> {d, Date.add(d, 1)} end)
    |> Stream.take_while(& Date.compare(&1, %{date | year: date.year + 1}) == :lt)
    |> Stream.filter(func)
  end

  def days_in_year_for(date, {which, day}, week_start)
    when is_atom(day) do
    days_in_year_for(date, {which, Day.of_week(day, week_start)}, week_start)
  end

  def days_in_year_for(date, {which, day}, week_start)
    when is_integer(day) and which > 0 do
    found = date
    |> days_in_year(& Day.of_week(&1, week_start) == day)
    |> Enum.at(which-1)
    if is_nil(found), do: [], else: [found]
  end

  def days_in_year_for(date, {which, day}, week_start)
    when is_integer(day) and which < 0 do
    found =
    date
    |> days_in_year(& Day.of_week(&1, week_start) == day)
    |> Enum.reverse()
    |> Enum.at(-which-1)
    if is_nil(found), do: [], else: [found]
  end

  def days_in_month(date, func \\ &identity/1) do
    1..Date.days_in_month(date)
    |> Stream.map(& %{date | day: &1})
    |> Stream.filter(func)
  end

  def identity(x), do: x

  def days_in_month_for(date, {which, day}, week_start)
    when is_atom(day) do
    days_in_month_for(date, {which, Day.of_week(day, week_start)}, week_start)
  end

  def days_in_month_for(date, {which, day}, week_start)
    when is_integer(which) and is_integer(day) and which < 0 do
    found =
    date
    |> days_in_month_for(day, week_start)
    |> Enum.reverse()
    |> Enum.at(-which-1)

    if is_nil(found), do: [], else: [found]
  end

  def days_in_month_for(date, {which, day}, week_start)
    when is_integer(which) and is_integer(day) and which > 0 do
    found =
    date
    |> days_in_month_for(day, week_start)
    |> Enum.at(which-1)

    if is_nil(found), do: [], else: [found]
  end

  def days_in_month_for(date, day, week_start)
    when is_atom(day) do
    date
    |> days_in_month(& Day.of_week(&1, week_start) == Day.of_week(day, week_start))
  end

  def days_in_month_for(date, day, week_start)
    when is_integer(day) do
    date
    |> days_in_month(& Day.of_week(&1, week_start) == day)
  end

  def day_for(date, which, _week_start)
    when is_integer(which) and which < 0 do
    [%{date | day: Date.days_in_month(date) + 1 - which}]
  end

  def day_for(date, which, _week_start)
    when is_integer(which) and which > 0 do
    [%{date | day: which}]
  end

  def day_for(date, {which, day}, week_start)
    when is_integer(which) and is_atom(day),
    do: day_for(date, {which, Day.of_week(day, week_start)}, week_start)

  def day_for(date, {_which, day} = which_day_of_week, week_start)
    when is_integer(day) do
    date
    |> days_in_month_for(which_day_of_week, week_start)
    |> Enum.at(0)
  end

  def day_for(date, day, week_start) when is_atom(day) do
    dow1 = Day.of_week(date, week_start)
    dow2 = Day.of_week(day, week_start)
    Date.add(date, dow2 - dow1)
  end
end

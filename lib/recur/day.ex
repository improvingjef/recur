defmodule Recur.Day do

  alias Recur.Days

  @week_days %{monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7}

  def of_week(day, week_start) when is_atom(day) do
    of_week(@week_days[day], week_start)
  end

  def of_week(dow, week_start) when is_integer(dow) do
    base_dow = @week_days[week_start]
    num = if dow < base_dow, do: 7, else: 0
    rem(num + dow - base_dow, 7) + 1
  end

  def of_week({_which, day}, week_start) when is_integer(day) or is_atom(day) do
    of_week(day, week_start)
  end

  def of_week(%Date{} = date, week_start) do
    date
    |> Date.day_of_week()
    |> of_week(week_start)
  end

  def which_week(day) when is_integer(day), do: (day / 7.0) |> Float.ceil(0) |> round()
  def which_week(%Date{} = date), do: which_week(date.day)
  def which_week(which, date), do: which_week(which_day(which, date))

  def of_which_week(which, date, week_start) do
    {which_week(which, date), of_week(date, week_start)}
  end

  def matches?(date, {which, day_of_week}, week_start)
    when is_atom(day_of_week) do
    of_which_week(which, date, week_start) == {which, of_week(day_of_week, week_start)}
  end

  def matches?(date, day_of_week, week_start)
    when is_atom(day_of_week) do
    of_week(date, week_start) == of_week(day_of_week, week_start)
  end

  def which_day(which, date) when which > 0,
    do: date.day

  def which_day(which, date) when which < 0,
    do: (Date.days_in_month(date) + 1 - date.day) * -1

  def for(date, which, _week_start)
    when is_integer(which) and which < 0 do
    [%{date | day: Date.days_in_month(date) + 1 - which}]
  end

  def for(date, which, _week_start)
    when is_integer(which) and which > 0 do
    [%{date | day: which}]
  end

  def for(date, {which, day}, week_start)
    when is_integer(which) and is_atom(day),
    do: __MODULE__.for(date, {which, of_week(day, week_start)}, week_start)

  def for(date, {_which, day} = which_day_of_week, week_start)
    when is_integer(day) do
    date
    |> Days.in_month_for(which_day_of_week, week_start)
    |> Enum.at(0)
  end

  def for(date, day, week_start) when is_atom(day) do
    dow1 = of_week(date, week_start)
    dow2 = of_week(day, week_start)
    Date.add(date, dow2 - dow1)
  end

  def of_year(date) do
    _jan1 = %{date | month: 1, day: 1}
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
end

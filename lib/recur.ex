defmodule Recur do
  alias Recur.{Day, Days, Week}
  @moduledoc """
    Recur does not deal with recurrence for Hours, Minutes, and Seconds,
    so the following elements of the recurrence portion of the iCal spec
    are all that we will attempt to address. The cell values that are
    ALL CAPS are addressed in the current revision. Mixed or lower
    case values have yet to be addressed.

    +-------+------+-------+------+
    |DAILY  |WEEKLY|MONTHLY|YEARLY|
    +-------+------+-------+------+
    |LIMT   |LIMIT |EXPAND |EXPAND| ByMonth
    +-------+------+-------+------+
    |N/A    |N/A   |N/A    |expand| ByWeekNo
    +-------+------+-------+------+
    |N/A    |N/A   |N/A    |EXPAND| ByYearDay
    +-------+------+-------+------+
    |LIMIT  |N/A   |EXPAND |EXPAND| ByMonthDay
    +-------+------+-------+------+
    |limit  |expand|NOTE 1 |Note 2| ByDay
    +-------+------+-------+------+

    Note 1:
      Limit if BYMONTHDAY is present; otherwise, special expand
      for MONTHLY.

    Note 2:
      Limit if BYYEARDAY or BYMONTHDAY is present; otherwise,
      special expand for WEEKLY if BYWEEKNO present; otherwise,
      special expand for MONTHLY if BYMONTH present; otherwise,
      special expand for YEARLY.
  """

  def unfold(%{frequency: frequency, by_week_no: _}) when frequency != :yearly,
    do: raise ArgumentError, "by_week_no may only be specified with the :yearly frequency. Got #{frequency}."

  def unfold(%{count: _, until: _}),
    do: raise ArgumentError, message: "recurrence rules may not contain both 'count' and 'until' values."

  def unfold(%{by_week_no: _}),
    do: raise ArgumentError, message: "by_week_no is not currently supported."

  def unfold(%{start_date: start_date} = rules) do
    rules =
      if Map.has_key?(rules, :week_start) do
        rules
      else
        Map.put(rules, :week_start, :monday)
      end

    rules
    |> frequency()
    |> interval(rules)
    |> by(rules)
    |> by_set_position(rules)
    |> Stream.reject(& Date.compare(&1, start_date) == :lt)
    |> terminate(rules)
    |> prime(start_date)
  end

  def take(rules, count) do
    rules
    |> unfold()
    |> Enum.take(count)
  end

  def prime(dates, start_date) do
    if Enum.at(dates, 0) == start_date do
      dates
    else
      Stream.concat([start_date], dates)
    end
  end

  def frequency(%{start_date: start_date, frequency: :yearly}) do
    Stream.unfold(start_date, fn date -> {date, %{date | year: date.year + 1}} end)
  end

  def frequency(%{start_date: start_date, frequency: :monthly}) do
    monthly(start_date)
  end

  def frequency(%{start_date: start_date, frequency: :weekly}),
    do: Stream.unfold(start_date, fn date -> {date, Date.add(date, 7)} end)

  def frequency(%{start_date: start_date, frequency: :daily}),
    do: Stream.unfold(start_date, fn date -> {date, Date.add(date, 1)} end)

  def frequency(%{frequency: frequency}),
    do: raise ArgumentError, "frequency #{frequency} is not supported."

  def monthly(start_date) do
    1..12
    |> Stream.cycle()
    |> Stream.drop(start_date.month-1)
    |> chunk_cycle()
    |> Stream.with_index()
    |> Stream.flat_map(fn {months, year_offset} ->
      Enum.map(months, fn month -> %{start_date | year: start_date.year + year_offset, month: month}  end) end)
  end

  def interval(dates, %{interval: interval}), do: Stream.take_every(dates, interval)
  def interval(dates, _), do: dates

  def terminate(dates, rules) do
    case rules do
      %{count: count} -> Stream.take(dates, count)
      %{until: until} -> Stream.take_while(dates, fn date -> Elixir.Date.compare(until, date) in [:gt, :eq] end)
      _ -> dates
    end
  end

  def chunk_cycle(stream), do: chunk_cycle(stream, & &1)

  def chunk_cycle(stream, func) do
    stream
    |> Stream.chunk_while([],
      fn i, chunk ->
        if not is_nil(List.last(chunk)) && chunk |> List.last() |> func.() >= func.(i) do
          {:cont, chunk, [i]}
        else
          {:cont, chunk ++ [i]}
        end
      end,
      fn chunk -> {:cont, chunk} end
    )
  end

  def by_set_position(dates, %{frequency: frequency, by_set_position: positions, week_start: week_start}) do
    dates
    |> Stream.chunk_by(chunk_func(frequency, week_start))
    |> Stream.flat_map(& positions |> Enum.map(fn position -> get_position(&1, position) end))
  end

  def by_set_position(dates, _rules) do
    dates
  end

  def get_position(dates, position) do
    cond do
      position > 0 -> Enum.at(dates, position-1)
      position < 0 -> dates |> Enum.reverse() |> Enum.at(-position-1)
    end
  end

  def chunk_func(frequency, week_start) do
    case frequency do
      :yearly -> fn d -> d.year end
      :monthly -> fn d -> d.month end
      :weekly -> fn d -> Week.of_year(d, week_start) end
      :daily -> fn d -> d end
    end
  end

  def by(dates, rules) do
    dates
    |> Stream.flat_map(& by(&1, :by_month,      rules))
    |> Stream.flat_map(& by(&1, :by_week_no,    rules))
    |> Stream.flat_map(& by(&1, :by_year_day,   rules))
    |> Stream.flat_map(& by(&1, :by_month_day,  rules))
    |> Stream.flat_map(& by(&1, :by_day,        rules))
  end

  def by(date, :by_month, %{frequency: :yearly, by_month: months}) do
    months
    |> wrap()
    |> Stream.map(&%{date | month: &1})
    |> Enum.sort(fn first, second -> Date.to_erl(first) < Date.to_erl(second) end)
  end

  def by(date, :by_month, %{frequency: frequency, by_month: months})
    when frequency in [:daily, :weekly, :monthly] do
    if months |> wrap() |> Enum.any?(& &1 == date.month), do: [date], else: []
  end

  def by(date, :by_year_day, %{frequency: :yearly, by_year_day: days}) do
    days
    |> wrap()
    |> Stream.map(&to_year_day(date, &1))
    |> Enum.sort(fn first, second -> Date.to_erl(first) < Date.to_erl(second) end)
  end

  def by(date, :by_month_day, %{frequency: :daily, by_month_day: days}) do
    if days |> wrap() |> Enum.any?(& &1 == date.day), do: [date], else: []
  end

  def by(date, :by_month_day, %{frequency: frequency, by_month_day: days})
    when frequency in [:yearly, :monthly] do
    map_month_days(date, days |> wrap())
  end

  def by(date, :by_day, %{frequency: :weekly, by_day: days, week_start: week_start}) do
    days
    |> wrap()
    |> Stream.map(&Day.for(date, &1, week_start))
    |> Enum.sort(fn first, second -> Date.to_erl(first) < Date.to_erl(second) end)
  end

  def by(date, :by_day, %{frequency: frequency, by_month_day: _, by_day: days, week_start: week_start})
    when frequency in [:monthly, :yearly], do: limit(date, wrap(days), week_start)

  def by(date, :by_day, %{frequency: :monthly, by_day: days, week_start: week_start}) do
    days
    |> wrap()
    |> Stream.flat_map(&Days.in_month_for(date, &1, week_start))
    |> Enum.sort(fn first, second -> Date.to_erl(first) < Date.to_erl(second) end)
  end

  def by(date, :by_day, %{frequency: :daily, by_day: days, week_start: week_start}) do
    limit(date, wrap(days), week_start)
  end

  def by(date, :by_day, %{frequency: :yearly, by_month: _, by_day: days, week_start: week_start}) do
    days
    |> wrap()
    |> Stream.flat_map(& Days.in_month_for(date, &1, week_start))
    |> Enum.sort(fn first, second -> Date.to_erl(first) < Date.to_erl(second) end)
  end

  def by(date, :by_day, %{frequency: :yearly, by_year_day: _, by_day: days, week_start: week_start}) do
    limit(date, wrap(days), week_start)
  end

  def by(date, :by_day, %{frequency: :yearly, by_day: days, week_start: week_start}) do
    days
    |> wrap()
    |> Stream.flat_map(& Days.in_year_for(date, &1, week_start))
    |> Enum.sort(fn first, second -> Date.to_erl(first) < Date.to_erl(second) end)
  end

  def by(date, _, _), do: [date]

  def limit(date, days, week_start),
    do: if Enum.any?(days, & Day.matches?(date, &1, week_start)), do: [date], else: []

  def map_month_day(day, days_in_month) when day < 0 do
    days_in_month + 1 + max(day, -days_in_month)
  end

  def map_month_day(day, days_in_month) when day > 0 do
    min(day, days_in_month)
  end

  def map_month_days(date, days) do
    days
    |> Stream.map(&map_month_day(&1, Date.days_in_month(date)))
    |> Stream.uniq()
    |> Stream.map(&%{date | day: &1})
    |> Enum.sort(fn first, second -> Date.to_erl(first) < Date.to_erl(second) end)
  end

  def to_year_day(date, year_day) do
    days_in_year = if Date.leap_year?(date), do: 366, else: 365
    year_day = min(year_day, days_in_year)

    if year_day > 0 do
      %{date | month:  1, day:  1} |> Date.add(year_day - 1)
    else
      %{date | month: 12, day: 31} |> Date.add(year_day + 1)
    end
  end

  def wrap(value) when is_list(value), do: value
  def wrap(value), do: [value]
end

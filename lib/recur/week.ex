defmodule Recur.Week do
  alias Recur.Day

  def of_year(date, week_start) do
    jan1 = %{date | month: 1, day: 1}
    jan1_dow = Day.of_week(jan1, week_start)
    days =
      cond do
        jan1_dow < 5 -> (Day.of_year(date) + 1)
        date.month == 1 and date.day <= (8 - jan1_dow) ->
          date.day + 1 + Day.of_year(%{date | year: date.year - 1, month: 12, day: 31})
        true -> (Day.of_year(date) + 1 - (8 - jan1_dow))
      end

    (days / 7.0 ) |> Float.ceil(0) |> round()
  end
end

defmodule GeneratorTest do
  use ExUnit.Case, async: true

  alias Recur, as: RR

  test "generates the first of the year" do
    dates = RR.unfold(%{frequency: :yearly, start_date: ~D[1999-01-01], until: ~D[2017-02-01]})
    assert 19 == dates |> Enum.count()
  end

  test "generates the first of jan, feb of the years" do
    dates = RR.unfold(%{frequency: :yearly, by_month: [1,2], start_date: ~D[1999-01-01], until: ~D[2017-02-01]})
    assert 38 == dates |> Enum.count()
  end

  test "generates the 1st and 2nd of jan, feb of the years" do
    dates = RR.unfold(%{frequency: :yearly, by_month: [1,2], by_month_day: [1,2], start_date: ~D[1999-01-01], until: ~D[2017-02-01]})
    assert 38 * 2 - 1 == dates |> Enum.count()
  end

  test "generates the first of the month" do
    months = RR.unfold(%{frequency: :monthly, start_date: ~D[1999-01-01], until: ~D[2000-02-01]})
    assert 14 == months |> Enum.count()
  end

  test "generates daily for a year" do
    months = RR.unfold(%{frequency: :daily, start_date: ~D[1999-01-01], until: ~D[1999-12-31]})
    assert 365 == months |> Enum.count()
  end

  test "by_month_day limits daily" do
    months = RR.unfold(%{frequency: :daily, by_month_day: [1,2], start_date: ~D[1999-01-01], until: ~D[1999-12-31]})
    assert 24 == months |> Enum.count()
  end

  test "by_day limits daily" do
    days = RR.unfold(%{frequency: :daily, by_day: [:friday], by_month_day: [1,2,3,4,5,6,7], start_date: ~D[1999-01-01], until: ~D[1999-12-31]})
    assert 12 == days |> Enum.to_list() |> Enum.map(& Date.day_of_week(&1)) |> Enum.count()
  end
end

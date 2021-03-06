defmodule Recur.WeekTest do
  use ExUnit.Case, async: true

  alias Recur.Days

  test "days_in_month - non-leap year" do
    assert 31 == Days.in_month(~D[2017-01-01]) |> Enum.count()
    assert 28 == Days.in_month(~D[2017-02-01]) |> Enum.count()
    assert 31 == Days.in_month(~D[2017-03-01]) |> Enum.count()
    assert 30 == Days.in_month(~D[2017-04-01]) |> Enum.count()
    assert 31 == Days.in_month(~D[2017-05-01]) |> Enum.count()
    assert 30 == Days.in_month(~D[2017-06-01]) |> Enum.count()

    assert 31 == Days.in_month(~D[2017-07-01]) |> Enum.count()
    assert 31 == Days.in_month(~D[2017-08-01]) |> Enum.count()
    assert 30 == Days.in_month(~D[2017-09-01]) |> Enum.count()
    assert 31 == Days.in_month(~D[2017-10-01]) |> Enum.count()
    assert 30 == Days.in_month(~D[2017-11-01]) |> Enum.count()
    assert 31 == Days.in_month(~D[2017-12-01]) |> Enum.count()
  end

  test "days_in_month - leap year" do
    assert 31 == Days.in_month(~D[2016-01-01]) |> Enum.count()
    assert 29 == Days.in_month(~D[2016-02-01]) |> Enum.count()
    assert 31 == Days.in_month(~D[2016-03-01]) |> Enum.count()
    assert 30 == Days.in_month(~D[2016-04-01]) |> Enum.count()
    assert 31 == Days.in_month(~D[2016-05-01]) |> Enum.count()
    assert 30 == Days.in_month(~D[2016-06-01]) |> Enum.count()

    assert 31 == Days.in_month(~D[2016-07-01]) |> Enum.count()
    assert 31 == Days.in_month(~D[2016-08-01]) |> Enum.count()
    assert 30 == Days.in_month(~D[2016-09-01]) |> Enum.count()
    assert 31 == Days.in_month(~D[2016-10-01]) |> Enum.count()
    assert 30 == Days.in_month(~D[2016-11-01]) |> Enum.count()
    assert 31 == Days.in_month(~D[2016-12-01]) |> Enum.count()
  end

  test "days.in_month_for which and day" do
    assert [~D[2017-01-01]] == Days.in_month_for(~D[2017-01-01], {1,:sunday}, :monday) |> Enum.to_list()
    assert [~D[2017-01-08]] == Days.in_month_for(~D[2017-01-01], {2,:sunday}, :monday) |> Enum.to_list()
    assert [~D[2017-01-15]] == Days.in_month_for(~D[2017-01-01], {3,:sunday}, :monday) |> Enum.to_list()
    assert [~D[2017-01-22]] == Days.in_month_for(~D[2017-01-01], {4,:sunday}, :monday) |> Enum.to_list()
    assert [~D[2017-01-29]] == Days.in_month_for(~D[2017-01-01], {5,:sunday}, :monday) |> Enum.to_list()

    assert [~D[2017-01-01]] == Days.in_month_for(~D[2017-01-01], {1,:sunday}, :tuesday) |> Enum.to_list()
    assert [~D[2017-01-08]] == Days.in_month_for(~D[2017-01-01], {2,:sunday}, :tuesday) |> Enum.to_list()
    assert [~D[2017-01-15]] == Days.in_month_for(~D[2017-01-01], {3,:sunday}, :tuesday) |> Enum.to_list()
    assert [~D[2017-01-22]] == Days.in_month_for(~D[2017-01-01], {4,:sunday}, :tuesday) |> Enum.to_list()
    assert [~D[2017-01-29]] == Days.in_month_for(~D[2017-01-01], {5,:sunday}, :tuesday) |> Enum.to_list()
  end

  test "days.in_month_for atom day" do
    assert [~D[2017-01-01], ~D[2017-01-08], ~D[2017-01-15], ~D[2017-01-22], ~D[2017-01-29]]
    == Days.in_month_for(~D[2017-01-01], :sunday, :monday) |> Enum.to_list()

    assert [~D[2017-01-01], ~D[2017-01-08], ~D[2017-01-15], ~D[2017-01-22], ~D[2017-01-29]]
    == Days.in_month_for(~D[2017-01-01], :sunday, :tuesday) |> Enum.to_list()
  end
end

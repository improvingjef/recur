defmodule DayTest do
  use ExUnit.Case, async: true

  alias Recur.Day
  @first_sunday ~D[2017-01-01]
  test "of_week with date" do
    assert 7 == Day.of_week(@first_sunday, :monday)
    assert 6 == Day.of_week(@first_sunday, :tuesday)
    assert 5 == Day.of_week(@first_sunday, :wednesday)
    assert 4 == Day.of_week(@first_sunday, :thursday)
    assert 3 == Day.of_week(@first_sunday, :friday)
    assert 2 == Day.of_week(@first_sunday, :saturday)
    assert 1 == Day.of_week(@first_sunday, :sunday)
  end

  test "of_week with atom dow" do
    assert 7 == Day.of_week(:sunday, :monday)
    assert 6 == Day.of_week(:sunday, :tuesday)
    assert 5 == Day.of_week(:sunday, :wednesday)
    assert 4 == Day.of_week(:sunday, :thursday)
    assert 3 == Day.of_week(:sunday, :friday)
    assert 2 == Day.of_week(:sunday, :saturday)
    assert 1 == Day.of_week(:sunday, :sunday)


    assert 1 == Day.of_week(:monday, :monday)
    assert 1 == Day.of_week(:tuesday, :tuesday)
    assert 1 == Day.of_week(:wednesday, :wednesday)
    assert 1 == Day.of_week(:thursday, :thursday)
    assert 1 == Day.of_week(:friday, :friday)
    assert 1 == Day.of_week(:saturday, :saturday)
    assert 1 == Day.of_week(:sunday, :sunday)
  end

  test "of_week with integer dow" do
    assert 7 == Day.of_week(7, :monday)
    assert 6 == Day.of_week(7, :tuesday)
    assert 5 == Day.of_week(7, :wednesday)
    assert 4 == Day.of_week(7, :thursday)
    assert 3 == Day.of_week(7, :friday)
    assert 2 == Day.of_week(7, :saturday)
    assert 1 == Day.of_week(7, :sunday)

    assert 1 == Day.of_week(1, :monday)
    assert 1 == Day.of_week(2, :tuesday)
    assert 1 == Day.of_week(3, :wednesday)
    assert 1 == Day.of_week(4, :thursday)
    assert 1 == Day.of_week(5, :friday)
    assert 1 == Day.of_week(6, :saturday)
    assert 1 == Day.of_week(7, :sunday)
  end


  test "which_week" do
    assert 1 == Day.which_week(@first_sunday)
    assert 2 == Day.which_week(Date.add(@first_sunday, 7))
    assert 1 == Day.which_week(Date.add(@first_sunday, 31))
  end

  test "matches with date" do
    assert Day.matches?(@first_sunday, :sunday, :monday)
  end

  test "matches with date and which week" do
    assert Day.matches?(@first_sunday, {1,:sunday}, :monday)
    assert Day.matches?(@first_sunday, {1,:sunday}, :tuesday)
    assert Day.matches?(@first_sunday, {1,:sunday}, :wednesday)
    assert Day.matches?(@first_sunday, {1,:sunday}, :thursday)
    assert Day.matches?(@first_sunday, {1,:sunday}, :friday)
  end

  test "which_day positive" do
    assert 1..31
      |> Enum.to_list()
      ==
      1..31
      |> Enum.map(& %{~D[2017-01-01] | day: &1})
      |> Enum.map(&Day.which_day(1, &1))
      |> Enum.to_list()
  end

  test "which_day negative" do
    assert 1..31
      |> Enum.map(& -&1)
      |> Enum.reverse()
      |> Enum.to_list()
      ==
      1..31
      |> Enum.map(& %{~D[2017-01-01] | day: &1})
      |> Enum.map(&Day.which_day(-1, &1))
      |> Enum.to_list()
  end

  test "Day.for which and dow" do
    assert ~D[2017-01-01] == Day.for(~D[2017-01-01], {1, :sunday}, :monday)
    assert ~D[2017-01-02] == Day.for(~D[2017-01-01], {1, :monday}, :monday)
    assert ~D[2017-01-03] == Day.for(~D[2017-01-01], {1, :tuesday}, :monday)
    assert ~D[2017-01-04] == Day.for(~D[2017-01-01], {1, :wednesday}, :monday)
    assert ~D[2017-01-05] == Day.for(~D[2017-01-01], {1, :thursday}, :monday)
    assert ~D[2017-01-06] == Day.for(~D[2017-01-01], {1, :friday}, :monday)
    assert ~D[2017-01-07] == Day.for(~D[2017-01-01], {1, :saturday}, :monday)
  end
end

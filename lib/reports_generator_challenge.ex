defmodule ReportsGeneratorChallenge do
  alias ReportsGeneratorChallenge.Parser

  @months %{
    1 => "janeiro",
    2 => "fevereiro",
    3 => "março",
    4 => "abril",
    5 => "maio",
    6 => "junho",
    7 => "julho",
    8 => "agosto",
    9 => "setembro",
    10 => "outubro",
    11 => "novembro",
    12 => "dezembro",
  }

  def build(filename) do
    Parser.parse_file(filename)
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
  end

  def build_from_many(filenames) when not is_list(filenames), do: {:error, "Please provide a list of strings"}

  def build_from_many(filenames) do
    result = filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)

    {:ok, result}
  end

  defp sum_reports(%{
      "all_hours" => all_hours1,
      "hours_per_month" => hours_per_month1,
      "hours_per_year" => hours_per_year1,
    }, %{
      "all_hours" => all_hours2,
      "hours_per_month" => hours_per_month2,
      "hours_per_year" => hours_per_year2,
    }) do
    all_hours = merge_maps(all_hours1, all_hours2)
    hours_per_month = merge_maps_maps(hours_per_month1, hours_per_month2)
    hours_per_year = merge_maps_maps(hours_per_year1, hours_per_year2)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp merge_maps_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> merge_maps(value1, value2) end)
  end

  defp sum_values([name, work_hours, _day, month, year], %{
    "all_hours" => all_hours,
    "hours_per_month" => hours_per_month,
    "hours_per_year" => hours_per_year
  }) do
    all_hours = Map.put(all_hours, name, add_to_all_hours(all_hours[name], work_hours))
    hours_per_month = Map.put(hours_per_month, name, add_to_hours_per_month(hours_per_month[name], month, work_hours))
    hours_per_year = Map.put(hours_per_year, name, add_to_hours_per_year(hours_per_year[name], year, work_hours))

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp report_acc do
    build_report(%{}, %{}, %{})
  end

  defp build_report(all_hours, hours_per_month, hours_per_year), do: %{
    "all_hours" => all_hours,
    "hours_per_month" => hours_per_month,
    "hours_per_year" => hours_per_year
  }

  defp add_to_all_hours(nil, hoursToAdd), do: hoursToAdd
  defp add_to_all_hours(currentHours, hoursToAdd), do: currentHours + hoursToAdd


  defp add_to_hours_per_month(nil, month, hoursToAdd), do: Map.put(%{}, @months[month], hoursToAdd)
  defp add_to_hours_per_month(map, month, hoursToAdd), do: add_to_hours_per_month_execute(map, month, map[@months[month]], hoursToAdd)

  defp add_to_hours_per_month_execute(map, month, nil, hoursToAdd), do: Map.put(map, @months[month], hoursToAdd)
  defp add_to_hours_per_month_execute(map, month, currentHours, hoursToAdd), do: Map.put(map, @months[month], currentHours + hoursToAdd)

  defp add_to_hours_per_year(nil, year, hoursToAdd), do: Map.put(%{}, year, hoursToAdd)
  defp add_to_hours_per_year(map, year, hoursToAdd), do: add_to_hours_per_year_execute(map, year, map[year], hoursToAdd)

  defp add_to_hours_per_year_execute(map, year, nil, hoursToAdd), do: Map.put(map, year, hoursToAdd)
  defp add_to_hours_per_year_execute(map, year, currentHours, hoursToAdd), do: Map.put(map, year, currentHours + hoursToAdd)

end

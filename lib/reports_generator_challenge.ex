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

  def build do
    Parser.parse_file("report.csv")
    |> Enum.reduce(report_acc(), fn line, report -> sum_values(line, report) end)
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

require 'pry'

class HeadcountAnalyst

  def initialize(dr)
    @dr = dr
  end

  def kindergarten_participation_rate_variation(dname, against)
    find_average_participation(@dr.find_by_name(dname)) / find_average_participation(@dr.find_by_name(against[:against])).to_f
  end

  def find_average_participation(district)
    district.enrollment.data[:kindergarten_participation].reduce(0) do |result, year|
      result += year[1]
      result
    end./district.enrollment.data[:kindergarten_participation].values.length
  end

  def kindergarten_participation_rate_variation_trend(dname, against)
    first_district = find_enrollment_data(dname)
    second_district = find_enrollment_data(against[:against])
    first_district.reduce({}) do |result, (year, percent)|
      result[year] = percent / second_district[year]
      result
    end
  end

  def find_enrollment_data(name)
    @dr.find_by_name(name).enrollment.data[:kindergarten_participation]
  end
end

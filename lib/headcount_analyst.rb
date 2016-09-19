require 'pry'

class HeadcountAnalyst

  def initialize(dr)
    @dr = dr
  end

  def kindergarten_participation_rate_variation(dname, against)
    find_average_participation(@dr.find_by_name(dname), :kindergarten_participation) / find_average_participation(@dr.find_by_name(against[:against]), :kindergarten_participation)
  end

  def find_average_participation(district, key)
    district.enrollment.data[key].reduce(0) do |result, year|
      result += year[1]
      result
    end./district.enrollment.data[key].values.length
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

  def kindergarten_participation_against_high_school_graduation(district)
    kindergarten_key = :kindergarten_participation
    highschool_key = :high_school_graduation

    kindergarten_variation = find_average_participation(@dr.find_by_name(district), kindergarten_key) / find_average_participation(@dr.find_by_name("COLORADO"), kindergarten_key)
    highschool_variation = find_average_participation(@dr.find_by_name(district), highschool_key) / find_average_participation(@dr.find_by_name("COLORADO"), highschool_key)
    kindergarten_variation / highschool_variation
  end

  def kindergarten_participation_correlates_with_high_school_graduation(district)
    return statewide_kindergarten_participation_correlation if district[:for] == 'STATEWIDE'
    return multiple_district_kindergarten_participation_correlation(district[:across]) if district.keys.include?(:across)
    result = kindergarten_participation_against_high_school_graduation(district[:for])
    return true if 0.6 < result && result < 1.5
    return false
  end

  def statewide_kindergarten_participation_correlation
    correlating_districts = @dr.districts.values.reduce(0) do |result, district|
      result += 1 if kindergarten_participation_correlates_with_high_school_graduation(for: district.name)
      result
    end
    return true if (correlating_districts / @dr.districts.length) > 0.7
    return false
  end

  def multiple_district_kindergarten_participation_correlation(districts)
    full_districts = districts.reduce([]) do |result, district_name|
      result << @dr.find_by_name(district_name)
      result
    end
    correlating_districts = full_districts.reduce(0) do |result, district|
      result += 1 if kindergarten_participation_correlates_with_high_school_graduation(for: district.name)
      result
    end
    return true if (correlating_districts / full_districts.length) > 0.7
    return false
  end

end

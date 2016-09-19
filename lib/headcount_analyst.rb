require 'pry'

class HeadcountAnalyst

  def initialize(dr)
    @dr = dr
  end

  def find_grade(districts)
    return :third_grade if (districts[:grade] == 3)
    return :eighth_grade if (districts[:grade] == 8)
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

  def top_statewide_test_year_over_year_growth(districts)
    grade = find_grade(districts)
    all_districts_growth = find_growth_all_districts(districts, grade) if districts[:subject]
    all_districts_growth = find_growth_all_districts_all_subjects(districts, grade) unless districts[:subject]
    all_districts_growth = find_weighted_growth_all_districts_all_subjects(districts, grade) if districts[:weighting]
    return all_districts_growth.max_by { |district_growth| district_growth[1] } unless districts[:top]
    return all_districts_growth.sort_by { |district_growth| district_growth[1] }.last(districts[:top]).reverse
  end

  def find_growth_all_districts(districts, grade)
    @dr.statewide_repository.statewide.reduce([]) do |result, (district, statewide)|
      # range = statewide.data[grade].minmax_by { |year| year }.flatten
      range = find_min_max(districts, grade)
      growth = (range[3][districts[:subject]] - range[1][districts[:subject]]) / (range[2] - range[0])
      result << [district, growth]
      result
    end
  end

  def find_growth_all_districts_all_subjects(districts, grade)
    @dr.statewide_repository.statewide.reduce([]) do |result, (district, statewide)|
      # range = statewide.data[grade].minmax_by { |year| year }.flatten
      range = find_min_max(districts, grade)
      growth = (range[3].values.reduce(:+)/3 - range[1].values.reduce(:+)/3) / (range[2] - range[0])
      result << [district, growth]
      result
    end
  end

  def find_weighted_growth_all_districts_all_subjects(districts, grade)
    @dr.statewide_repository.statewide.reduce([]) do |result, (district, statewide)|
      # range = statewide.data[grade].minmax_by { |year| year }.flatten
      # binding.pry
      range = find_min_max(districts, grade)
      weighted_math = range[3][:math] * districts[:weighting][:math] / range[1][:math] * districts[:weighting][:math]
      weighted_writing = range[3][:writing] * districts[:weighting][:writing] / range[1][:writing] * districts[:weighting][:writing]
      weighted_reading = range[3][:reading] * districts[:weighting][:reading] / range[1][:reading] * districts[:weighting][:reading]
      growth = ((weighted_math + weighted_reading + weighted_writing) / 3) / (range[2] - range[0])
      result << [district, growth]
      result
    end
  end

  def find_min_max(districts, grade)
    find_max(districts, grade)
  end

  def find_min

  end

  def find_max(districts, grade)
    binding.pry
  end
end

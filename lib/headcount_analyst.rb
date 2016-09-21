require_relative '../lib/insufficient_information_error'
require 'pry'

class HeadcountAnalyst

  def initialize(dr)
    @dr = dr
  end

  def kindergarten_participation_rate_variation(dname, against)
    find_average_participation(@dr.find_by_name(dname), :kindergarten_participation).
      /find_average_participation(@dr.find_by_name(against[:against]), :kindergarten_participation)
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

    kindergarten_variation = find_average_participation(@dr.find_by_name(district), kindergarten_key).
      /find_average_participation(@dr.find_by_name("COLORADO"), kindergarten_key)
    highschool_variation = find_average_participation(@dr.find_by_name(district), highschool_key).
      /find_average_participation(@dr.find_by_name("COLORADO"), highschool_key)
    kindergarten_variation.
    /highschool_variation
  end

  def kindergarten_participation_correlates_with_high_school_graduation(dist)
    if dist[:for] == 'STATEWIDE'
      return statewide_kindergarten_participation_correlation
    elsif dist.keys.include?(:across)
      return multi_dist_kin_participation_correlation(dist[:across])
    end

    result =
      kindergarten_participation_against_high_school_graduation(dist[:for])

    if 0.6 < result && result < 1.5
      return true
    else
      return false
    end
  end

  def statewide_kindergarten_participation_correlation
    correlating_districts = @dr.districts.values.reduce(0) do |result, district|
      result += 1 if kindergarten_participation_correlates_with_high_school_graduation(for: district.name)
      result
    end
    return true if (correlating_districts / @dr.districts.length) > 0.7
    return false
  end

  def multi_dist_kin_participation_correlation(districts)
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

  def top_statewide_test_year_over_year_growth(testing_info)
    if invalid_grade?(testing_info[:grade])
      raise InsufficientInformationError.new("Invalid Grade")
    end

    testing_info[:grade] = find_grade(testing_info)

    if testing_info[:subject]
      return find_min_and_max_with_subject(testing_info)
    end

    unless testing_info[:subject]
      testing_info[:subject] = :math
      math_districts_growth = find_min_and_max(testing_info)
      testing_info[:subject] = :reading
      reading_districts_growth = find_min_and_max(testing_info)
      testing_info[:subject] = :writing
      writing_districts_growth = find_min_and_max(testing_info)
      all_districts_growth = average_districts_growth_across_subjects(math_districts_growth, reading_districts_growth, writing_districts_growth, testing_info)
      return all_districts_growth.max_by { |dg| dg[1] } unless testing_info[:top]
      return all_districts_growth.sort_by { |dg| dg[1] }.last(testing_info[:top]).reverse if testing_info[:top]
    end
  end

  def find_min_and_max_with_subject(testing_info)
    all_districts_growth = find_min_and_max(testing_info)
    return all_districts_growth.max_by { |dg| dg[1] } unless testing_info[:top]
    return all_districts_growth.sort_by { |dg| dg[1] }.last(testing_info[:top]).reverse if testing_info[:top]
  end

  def invalid_grade?(grade)
    grade != 3 && grade != 8
  end

  def find_grade(testing_info)
    return :third_grade if (testing_info[:grade] == 3)
    return :eighth_grade if (testing_info[:grade] == 8)
  end

  def find_min_and_max(testing_info)
    @dr.statewide_repository.statewide.reduce([]) do |result, (district, statewide)|

      unless testing_info[:weighting]
        max = find_max(statewide, testing_info[:grade], testing_info[:subject])
        min = find_min(statewide, testing_info[:grade], testing_info[:subject])
      end

      if testing_info[:weighting]
        max = find_max_with_weight(statewide, testing_info[:grade], testing_info[:subject], testing_info[:weighting])
        min = find_min_with_weight(statewide, testing_info[:grade], testing_info[:subject], testing_info[:weighting])
      end


      if max[0] == min[0] || ((max[1] - min[1]) / (max[0] - min[0])).to_f.nan?
        result << [district, 0]
      end

      unless max[0] == min[0] || ((max[1] - min[1]) / (max[0] - min[0])).to_f.nan?
        result << [district, ((max[1] - min[1]) / (max[0] - min[0]))]
      end

      result
    end
  end

  def find_max(statewide, grade, subject)
    removed_zeros = statewide.data[grade].dup
    removed_zeros.delete_if { |year, subjects| subjects[subject] == 0 || subjects[subject].nil? }
    max = removed_zeros.max_by { |year, subjects| year }
    return [max[0], max[1][subject]] unless max.nil?
    [1,0]
  end

  def find_min(statewide, grade, subject)
    removed_zeros = statewide.data[grade].dup
    removed_zeros.delete_if { |year, subjects| subjects[subject] == 0 || subjects[subject].nil? }
    min = removed_zeros.min_by { |year, subjects| year }
    return [min[0], min[1][subject]] unless min.nil?
    [0,0]
  end

  def find_max_with_weight(statewide, grade, subject, weighting)
    removed_zeros = statewide.data[grade].dup
    removed_zeros.delete_if { |year, subjects| subjects[subject] == 0 || subjects[subject].nil? }
    max = removed_zeros.max_by { |year, subjects| year }
    return [max[0], (max[1][subject] * weighting[subject])] unless max.nil?
    [1,0]
  end

  def find_min_with_weight(statewide, grade, subject, weighting)
    removed_zeros = statewide.data[grade].dup
    removed_zeros.delete_if { |year, subjects| subjects[subject] == 0 || subjects[subject].nil? }
    min = removed_zeros.min_by { |year, subjects| year }
    return [min[0], (min[1][subject] * weighting[subject])] unless min.nil?
    [0,0]
  end

  def average_districts_growth_across_subjects(math, reading, writing, testing_info)
    consolidated = consolidate_growth_to_district(math, reading, writing)
    return find_average(consolidated) unless testing_info[:weighting]
    return find_average_weighted(consolidated) if testing_info[:weighting]
  end

  def consolidate_growth_to_district(math, reading, writing)
    mashed = []

    math.each { |a| mashed << a }

    reading.each { |a| mashed << a }

    writing.each { |a| mashed << a }

    consolidated = mashed.group_by { |a| a[0] }
  end

  def find_average(consolidated)
    consolidated.reduce([]) do |result, (district, data)|
      average = (data[0][1] + data[1][1] + data[2][1]) / 3
      result << [district, average]
      result
    end
  end

  def find_average_weighted(consolidated)
    consolidated.reduce([]) do |result, (district, data)|
      average = (data[0][1] + data[1][1] + data[2][1])
      result << [district, average]
      result
    end
  end
end

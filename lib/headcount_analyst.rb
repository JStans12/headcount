require_relative '../lib/insufficient_information_error'
require 'pry'

class HeadcountAnalyst

  def initialize(dr)
    @dr = dr
  end

  def kindergarten_participation_rate_variation(dname, against)
    find_average_participation(
      @dr.find_by_name(dname), :kindergarten_participation).
        /find_average_participation(
          @dr.find_by_name(against[:against]), :kindergarten_participation)
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

    d = @dr.find_by_name(district)
    dc = @dr.find_by_name("COLORADO")

    kindergarten_variation = find_average_participation(d, kindergarten_key).
      /find_average_participation(dc, kindergarten_key)

    highschool_variation = find_average_participation(d, highschool_key).
      /find_average_participation(dc, highschool_key)

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

    return true if 0.6 < result && result < 1.5
    return false
  end

  def statewide_kindergarten_participation_correlation
    correlating_districts = @dr.districts.values.reduce(0) do |result, district|
      d = {for: district.name}
      if kindergarten_participation_correlates_with_high_school_graduation(d)
        result += 1
      end
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
    correlating_districts = find_correlating_districts(full_districts)

    return true if (correlating_districts / full_districts.length) > 0.7
    return false
  end

  def find_correlating_districts(full_districts)
    full_districts.reduce(0) do |result, district|
      d = {for: district.name}
      if kindergarten_participation_correlates_with_high_school_graduation(d)
        result += 1
      end
      result
    end
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
      math_dis_growth = find_min_and_max(testing_info)
      testing_info[:subject] = :reading
      reading_dis_growth = find_min_and_max(testing_info)
      testing_info[:subject] = :writing
      writing_dis_growth = find_min_and_max(testing_info)

      all_dis_growth = average_districts_growth_across_subjects(
        math_dis_growth, reading_dis_growth, writing_dis_growth, testing_info)

      return top_district(all_dis_growth) unless testing_info[:top]
      return top_num_districts(all_dis_growth, testing_info)
    end
  end

  def top_district(all_dis_growth)
    all_dis_growth.max_by { |dg| dg[1] }
  end

  def top_num_districts(all_dis_growth, testing_info)
    all_dis_growth.sort_by { |dg| dg[1] }.
      last(testing_info[:top]).reverse if testing_info[:top]
  end

  def find_min_and_max_with_subject(testing_info)
    all_dis_growth = find_min_and_max(testing_info)

    return top_district(all_dis_growth) unless testing_info[:top]
    return top_num_districts(all_dis_growth, testing_info)
  end

  def invalid_grade?(grade)
    grade != 3 && grade != 8
  end

  def find_grade(testing_info)
    return :third_grade if (testing_info[:grade] == 3)
    return :eighth_grade if (testing_info[:grade] == 8)
  end

  def find_min_and_max(testing_info)
    @dr.statewide_repository.statewide.reduce([]) do |result, (dist, statewide)|

      t_grade = testing_info[:grade]
      t_sub = testing_info[:subject]
      t_weight = testing_info[:weighting]

      unless testing_info[:weighting]
        max = find_max(statewide, t_grade, t_sub)
        min = find_min(statewide, t_grade, t_sub)
      end

      if testing_info[:weighting]
        max = find_max_with_weight(statewide, t_grade, t_sub, t_weight)
        min = find_min_with_weight(statewide, t_grade, t_sub, t_weight)
      end

      result << [dist, 0] if is_nan?(max, min)
      result << [dist, growth_over_years(max, min)] unless is_nan?(max, min)

      result
    end
  end

  def is_nan?(max, min)
    max[0] == min[0] || ((max[1] - min[1]) / (max[0] - min[0])).to_f.nan?
  end

  def growth_over_years(max, min)
    ((max[1] - min[1]) / (max[0] - min[0]))
  end

  def find_max(statewide, grade, subject)
    years = statewide.data[grade].dup

    remove_zeros(years, subject)

    max = years.max_by { |year, subjects| year }
    return [max[0], max[1][subject]] unless max.nil?
    [1,0]
  end

  def find_min(statewide, grade, subject)
    years = statewide.data[grade].dup

    remove_zeros(years, subject)

    min = years.min_by { |year, subjects| year }
    return [min[0], min[1][subject]] unless min.nil?
    [0,0]
  end

  def find_max_with_weight(statewide, grade, subject, weighting)
    years = statewide.data[grade].dup

    remove_zeros(years, subject)

    max = years.max_by { |year, subjects| year }
    return [max[0], (max[1][subject] * weighting[subject])] unless max.nil?
    [1,0]
  end

  def find_min_with_weight(statewide, grade, subject, weighting)
    years = statewide.data[grade].dup

    remove_zeros(years, subject)

    min = years.min_by { |year, subjects| year }
    return [min[0], (min[1][subject] * weighting[subject])] unless min.nil?
    [0,0]
  end

  def remove_zeros(removed_zeros, subject)
    removed_zeros.delete_if do |year, subjects|
      subjects[subject] == 0 || subjects[subject].nil?
    end
  end

  def average_districts_growth_across_subjects(math, read, writin, testing_info)
    consolidated = consolidate_growth_to_district(math, read, writin)
    return find_average(consolidated) unless testing_info[:weighting]
    return find_average_weighted(consolidated) if testing_info[:weighting]
  end

  def consolidate_growth_to_district(math, reading, writing)
    mashed = []
    math.each { |a| mashed << a }
    reading.each { |a| mashed << a }
    writing.each { |a| mashed << a }

    mashed.group_by { |a| a[0] }
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

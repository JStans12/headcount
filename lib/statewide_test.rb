require_relative '../lib/unknown_data_error'
require 'pry'

class StatewideTest
  attr_reader :name, :data

  def initialize(data)
    @data = nil
    @name = data[:name]
    assign_data(data)
  end

  def assign_data(data)
    data_name = data.keys[1]
    @data = {data_name => data[data_name]}
  end

  def proficient_by_grade(grade)
    return @data[:third_grade] if grade == 3
    return @data[:eighth_grade] if grade == 8
    raise UnknownDataError.new("Unknown Data Error")
  end

  def proficient_by_race_or_ethnicity(race)
    raise UnknownDataError.new("Unknown Data Error") unless allowed_races.include?(race)
    math = find_subject_by_ethnicity(race, :math)
    reading = find_subject_by_ethnicity(race, :reading)
    writing = find_subject_by_ethnicity(race, :writing)
    years = (math.keys << reading.keys << writing.keys).flatten.uniq
    years.reduce({}) do |result, year|
      result[year] = { math: math[year].values[0], reading: reading[year].values[0], writing: writing[year].values[0] }
      result
    end
  end

  def find_subject_by_ethnicity(race, subject)
    @data[subject][race].reduce({}) do |result, (year, data)|
      result[year] = {subject => data}
      result
    end
  end

  def proficient_for_subject_by_grade_in_year(subject, grade, year)
    raise UnknownDataError.new("Unknown Data Error") unless allowed_subjects.include?(subject)
    grade_data = proficient_by_grade(grade)
    return grade_data[year][subject] unless grade_data[year][subject] == 0.0
    return "N/A"
  end

  def proficient_for_subject_by_race_in_year(subject, race, year)
    raise UnknownDataError.new("Unknown Data Error") unless allowed_subjects.include?(subject)
    ethnicity_data = proficient_by_race_or_ethnicity(race)
    return ethnicity_data[year][subject] unless ethnicity_data[year][subject] == 0.0
    return "N/A"
  end

  def allowed_subjects
    [:math, :reading, :writing]
  end

  def allowed_races
    [:asian, :all_students, :black, :pacific_islander, :hispanic, :native_american, :two_or_more, :white]
  end
end

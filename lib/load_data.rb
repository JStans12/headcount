require_relative '../lib/sanitizer'
require_relative '../lib/truncate'
require 'csv'
require 'pry'

module LoadData
  include Sanitizer
  include Truncate
  extend self

  def load_data(file_name)
    loaded_data = csv_parse(file_name)
    case file_name[0]

    when :enrollment
      return compile_enrollment(loaded_data, :kindergarten_participation) if file_name[1] == :kindergarten
      return compile_enrollment(loaded_data, :high_school_graduation) if file_name[1] == :high_school_graduation

    when :statewide_testing
      return compile_statewide_grade(loaded_data, :third_grade)if file_name[1] == :third_grade
      return compile_statewide_grade(loaded_data, :eighth_grade)if file_name[1] == :eighth_grade
      return compile_statewide_subject(loaded_data, :math)if file_name[1] == :math
      return compile_statewide_subject(loaded_data, :reading)if file_name[1] == :reading
      return compile_statewide_subject(loaded_data, :writing)if file_name[1] == :writing

    when :economic_profile
      return compile_economic_profile(loaded_data, :median_household_income) if file_name[1] == :median_household_income
      return compile_economic_profile(loaded_data, :children_in_poverty) if file_name[1] == :children_in_poverty
      return compile_free_lunch_data(loaded_data, :free_or_reduced_price_lunch) if file_name[1] == :free_or_reduced_price_lunch
      return compile_economic_profile(loaded_data, :title_i) if file_name[1] == :title_i

    end
  end

  def csv_parse(file_name)
    loaded_data = CSV.open file_name[2], headers: true, header_converters: :symbol
    sanitized_data = loaded_data.map { |line| Sanitizer.clean_line(line, file_name) }
    sanitized_data
  end

  def compile_enrollment(file_content, enrollment_type)
    file_content.reduce([]) do |compiled_enrollment, line|
      compiled_enrollment << hash_to_store_data(enrollment_type, line) unless district_is_included(compiled_enrollment, line)
      current_district = find_current_district(compiled_enrollment, line)
      add_data_to_existing_enrollment(current_district, line, enrollment_type)
      compiled_enrollment
    end
  end

  def add_data_to_existing_enrollment(current_enrollment, line, enrollment_type)
    current_enrollment[enrollment_type][line[:timeframe]] = line[:data]
  end

  def compile_statewide_grade(file_content, grade)
    file_content.reduce([]) do |compiled_statewide, line|
      compiled_statewide << hash_to_store_data(grade, line) unless district_is_included(compiled_statewide, line)
      current_district = find_current_district(compiled_statewide, line)
      current_district[grade] = Hash.new unless current_district[grade]
      current_district[grade][line[:timeframe]] = Hash.new unless current_district[grade][line[:timeframe]]
      current_year = current_district[grade][line[:timeframe]]
      current_year[line[:score]] = line[:data]
      compiled_statewide
    end
  end

  def compile_statewide_subject(file_content, subject)
    file_content.reduce([]) do |compiled_statewide, line|
      compiled_statewide << hash_to_store_data(subject, line) unless district_is_included(compiled_statewide, line)
      current_district = find_current_district(compiled_statewide, line)
      current_district[subject] = Hash.new unless current_district[subject]
      current_district[subject][line[:race_ethnicity]] = Hash.new unless current_district[subject][line[:race_ethnicity]]
      current_year = current_district[subject][line[:race_ethnicity]]
      current_year[line[:timeframe]] = line[:data]
      compiled_statewide
    end
  end

  def compile_economic_profile(file_content, median)
    file_content.reduce([]) do |compiled_economic_profile, line|
      compiled_economic_profile << hash_to_store_data(median, line) unless district_is_included(compiled_economic_profile, line)
      current_district = find_current_district(compiled_economic_profile, line)
      current_district[median][line[:timeframe]] = line[:data]
      compiled_economic_profile
    end
  end

  def compile_free_lunch_data(file_content, subject)
    file_content.reduce([]) do |compiled_economic_profile, line|
      compiled_economic_profile << hash_to_store_data(subject, line) unless district_is_included(compiled_economic_profile, line)
      current_district = find_current_district(compiled_economic_profile, line)
      current_district[subject][line[:timeframe]] = Hash.new unless current_district[subject][line[:timeframe]]
      current_year = current_district[subject][line[:timeframe]]
      current_year[:percentage] = line[:data] if line[:poverty_level] == "Eligible for Free or Reduced Lunch" && line[:dataformat] == "Percent"
      current_year[:total] = line[:data] if line[:poverty_level] == "Eligible for Free or Reduced Lunch" && line[:dataformat] == "Number"
      compiled_economic_profile
    end
  end

  def district_is_included(compiled, line)
    compiled.any? {|e| e.values.include?(line[:location])}
  end

  def hash_to_store_data(type, line)
    {name: line[:location], type => Hash.new}
  end

  def find_current_district(compiled, line)
    compiled.detect { |data| data.values.include?(line[:location]) }
  end

  # def year_is_included
  #   current_statewide_test[subject][line[:timeframe].to_i]
  # end
  #
  # POSSIBLILITIES TO BREAK DOWN #

  # # def year_is_included(grade, line)
  # #   grade.any? {|g| g.values.include?(line[:timeframe])}
  # # end
  #
  # def hash_to_store_subject(subject, line)
  #   {name: line[subject], subject => Hash.new}
  # end
  #
  # def subject_is_included(result, line, subject)
  #   result.any? {|e| e.values.include?(line[subject])}
  # end

end

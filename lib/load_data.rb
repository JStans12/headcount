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
      return distribute_enrollment(file_name, loaded_data)

    when :statewide_testing
      return distribute_statewide(file_name, loaded_data)

    when :economic_profile
      return distribute_economic(file_name, loaded_data)

    end
  end

  def distribute_enrollment(file_name, loaded_data)
    if file_name[1] == :kindergarten
      return compile_enrollment(loaded_data, :kindergarten_participation)
    end

    return compile_enrollment(loaded_data, file_name[1])
  end

  def distribute_statewide(file_name, loaded_data)
    if file_name[1] == :third_grade || file_name[1] == :eighth_grade
      return compile_statewide_grade(loaded_data,  file_name[1])
    end

    if file_name[1] == :math ||
       file_name[1] == :reading ||
       file_name[1] == :writing
      return compile_statewide_subject(loaded_data, file_name[1])
    end
  end

  def distribute_economic(file_name, loaded_data)
    if file_name[1] == :median_household_income ||
       file_name[1] == :title_i ||
       file_name[1] == :children_in_poverty
      return compile_economic_profile(loaded_data, file_name[1])

    else
      return compile_free_lunch_data(loaded_data,:free_or_reduced_price_lunch)
    end
  end

  def csv_parse(file_name)
    load_d = CSV.open file_name[2], headers: true, header_converters: :symbol
    sanitized_data = load_d.map { |line| Sanitizer.clean_line(line, file_name) }
    sanitized_data
  end

  def compile_enrollment(file_content, enrollment_type)
    file_content.reduce([]) do |compiled_enrollment, line|

      unless district_is_included(compiled_enrollment, line)
        compiled_enrollment << hash_to_store_data(enrollment_type, line)
      end

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

      create_hash_to_store_district(compiled_statewide, line, grade)
      current_district = find_current_district(compiled_statewide, line)
      create_hash_to_store_type(current_district, grade)
      create_hash_to_store_subtype(current_district, grade, line, :timeframe)
      current_year = find_current_year(current_district, grade, line)

      current_year[line[:score]] = line[:data]
      compiled_statewide
    end
  end

  def compile_statewide_subject(file_content, subject)
    file_content.reduce([]) do |compiled_statewide, line|

      create_hash_to_store_district(compiled_statewide, line, subject)
      current_district = find_current_district(compiled_statewide, line)
      create_hash_to_store_type(current_district, subject)
      create_hash_to_store_subtype( current_district, subject,
                                    line, :race_ethnicity )

      current_ethnicity = find_current_ethnicity(current_district,subject, line)
      current_ethnicity[line[:timeframe]] = line[:data]
      compiled_statewide
    end
  end

  def compile_economic_profile(file_content, sub_type)
    file_content.reduce([]) do |compiled_economic_profile, line|

      create_hash_to_store_district(compiled_economic_profile, line, sub_type)

      current_district = find_current_district(compiled_economic_profile, line)
      current_district[sub_type][line[:timeframe]] = line[:data]
      compiled_economic_profile
    end
  end

  def compile_free_lunch_data(file_content, subject)
    file_content.reduce([]) do |compiled_economic_profile, line|

      create_hash_to_store_district(compiled_economic_profile, line, subject)
      current_district = find_current_district(compiled_economic_profile, line)
      create_hash_to_store_subtype(current_district, subject, line, :timeframe)
      current_year = find_current_year(current_district, subject, line)

      find_percent_data(current_year, line)
      find_number_data(current_year, line)

      compiled_economic_profile
    end
  end

  def find_percent_data(current_year, line)
    if line[:poverty_level] == "Eligible for Free or Reduced Lunch" &&
       line[:dataformat] == "Percent"

       current_year[:percentage] = line[:data]
    end
  end

  def find_number_data(current_year, line)
    if line[:poverty_level] == "Eligible for Free or Reduced Lunch" &&
       line[:dataformat] == "Number"

       current_year[:total] = line[:data]
    end
  end

  def create_hash_to_store_district(compiled_statewide, line, grade)
    unless district_is_included(compiled_statewide, line)
      compiled_statewide << hash_to_store_data(grade, line)
    end
  end

  def create_hash_to_store_type(current_district, grade)
    unless current_district[grade]
      current_district[grade] = Hash.new
    end
  end

  def create_hash_to_store_subtype(current_district, type, line, subtype)
    unless current_district[type][line[subtype]]
      current_district[type][line[subtype]] = Hash.new
    end
  end

  def find_current_year(current_district, grade, line)
    current_district[grade][line[:timeframe]]
  end

  def find_current_ethnicity(current_district, subject, line)
    current_district[subject][line[:race_ethnicity]]
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
end

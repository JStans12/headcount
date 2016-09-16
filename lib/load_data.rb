require 'csv'
require 'pry'

module LoadData
  extend self

  def load_data(file_name)
    loaded_data = csv_parse(file_name[2])

    case file_name[0]

    when :enrollment
      return compile_names_enrollment(loaded_data, :kindergarten_participation) if file_name[1] == :kindergarten
      return compile_names_enrollment(loaded_data, :high_school_graduation) if file_name[1] == :high_school_graduation

    when :statewide_testing
      return compile_names_statewide_grade(loaded_data, :third_grade)if file_name[1] == :third_grade
      return compile_names_statewide_grade(loaded_data, :eighth_grade)if file_name[1] == :eighth_grade
      return compile_names_statewide(loaded_data, :math)if file_name[1] == :math
      return compile_names_statewide(loaded_data, :reading)if file_name[1] == :reading
      return compile_names_statewide(loaded_data, :writing)if file_name[1] == :writing

    end
  end

  def csv_parse(file_name)
    CSV.open file_name, headers: true, header_converters: :symbol
  end

  def compile_names_enrollment(file_content, enrollment_type)
    file_content.reduce([]) do |result, line|
      result << hash_to_store_data(enrollment_type, line) unless district_is_included(result, line)
      current_enrollment = result.detect { |h| h.values.include?(line[:location]) }
      add_data_to_existing_enrollment(current_enrollment, line, enrollment_type)
      result
    end
  end

  def district_is_included(result, line)
    result.any? {|e| e.values.include?(line[:location])}
  end

  def hash_to_store_data(type, line)
    {name: line[:location], type => Hash.new}
  end

  def add_data_to_existing_enrollment(current_enrollment, line, enrollment_type)
    current_enrollment[enrollment_type][line[:timeframe].to_i] = line[:data].to_f
  end

  def compile_names_statewide_grade(file_content, subject)
    file_content.reduce([]) do |result, line|
      result << hash_to_store_data(subject, line) unless district_is_included(result, line)
      current_grade = result.detect { |h| h.values.include?(line[:location]) }
      current_grade[subject] = Hash.new unless current_grade[subject]
      current_grade[subject][line[:timeframe]] = Hash.new unless current_grade[subject][line[:timeframe]]
      current_year = current_grade[subject][line[:timeframe]]
      current_year[line[:score]] = line[:data]
      result
    end
  end

  # def year_is_included(grade, line)
  #   grade.any? {|g| g.values.include?(line[:timeframe])}
  # end

  def hash_to_store_subject(subject, line)
    {name: line[subject], subject => Hash.new}
  end

  def subject_is_included(result, line, subject)
    result.any? {|e| e.values.include?(line[subject])}
  end

  def add_data_to_existing_subject(current_enrollment, line, subject)

  end

end

require 'csv'
require 'pry'

module LoadData
  extend self

  def load_data(file_name)
    loaded_data = csv_parse(file_name[2])
    return compile_names(loaded_data, :kindergarten_participation) if file_name[1] == :kindergarten
    return compile_names(loaded_data, :high_school_graduation) if file_name[1] == :high_school_graduation
  end

  def csv_parse(file_name)
    CSV.open file_name, headers: true, header_converters: :symbol
  end

  def compile_names(file_content, enrollment_type)
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

  def hash_to_store_data(enrollment_type, line)
    {name: line[:location], enrollment_type => Hash.new}
  end

  def add_data_to_existing_enrollment(current_enrollment, line, enrollment_type)
    current_enrollment[enrollment_type][line[:timeframe].to_i] = line[:data].to_f
  end
end

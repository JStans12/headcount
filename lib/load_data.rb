require 'csv'
require 'pry'

module LoadData
  extend self

  def load_data(file_name)
    loaded_data = csv_parse(file_name[1])
    return compile_names_kindergarten(loaded_data) if file_name[0] == :kindergarten
    return compile_names_graduation(loaded_data) if file_name[0] == :high_school_graduation
  end

  def csv_parse(file_name)
    CSV.open file_name, headers: true, header_converters: :symbol
  end

  def compile_names_kindergarten(file_content)
    file_content.reduce([]) do |result, line|
      result << {name: line[:location], kindergarten_participation: Hash.new} unless result.any? {|e| e.values.include?(line[:location])}
      current_enrollment = result.detect { |h| h.values.include?(line[:location])}
      current_enrollment[:kindergarten_participation][line[:timeframe].to_i] = line[:data].to_f
      result
    end
  end

  def compile_names_graduation(file_content)
    file_content.reduce([]) do |result, line|
      result << {name: line[:location], high_school_graduation: Hash.new} unless result.any? {|e| e.values.include?(line[:location])}
      current_enrollment = result.detect { |h| h.values.include?(line[:location])}
      current_enrollment[:high_school_graduation][line[:timeframe].to_i] = line[:data].to_f
      result
    end
  end
end

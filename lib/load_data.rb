require 'csv'
require './lib/district_repository'

module LoadData
  extend self

  def load_data_district(file_hash)
    file_name = file_hash[:enrollment][:kindergarten]
    loaded_data = csv_parse(file_name)
    compile_names_district(loaded_data)
  end

  def load_data_enrollment(file_hash)
    file_name = file_hash[:enrollment][:kindergarten]
    loaded_data = csv_parse(file_name)
    compile_names_enrollment(loaded_data)
  end

  def csv_parse(file_name)
    file_content = CSV.open file_name, headers: true, header_converters: :symbol
  end

  def compile_names_district(file_content)
    name_list = file_content.reduce([]) do |result, line|
      result << {name: line[:location]} unless result.any? {|e| e.values.include?(line[:location])}
      result
    end
  end

  def compile_names_enrollment(file_content)
    name_list = file_content.reduce([]) do |result, line|
      result << {name: line[:location], kindergarten_participation: Hash.new} unless result.any? {|e| e.values.include?(line[:location])}
      current_enrollment = result.detect { |h| h.values.include?(line[:location])}
      current_enrollment[:kindergarten_participation][line[:timeframe].to_i] = line[:data].to_f
      result
    end
  end
end

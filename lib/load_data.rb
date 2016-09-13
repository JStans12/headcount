require 'csv'
require './lib/district_repository'

module LoadData
  extend self

  def load_data(file_hash)
    file_name = file_hash[:enrollment][:kindergarten]
    csv_parse(file_name)
  end

  def csv_parse(file_name)
    file_content = CSV.open file_name, headers: true, header_converters: :symbol
    compile_names(file_content)
  end

  def compile_names(file_content)
    name_list = file_content.reduce([]) do |result, line|
      result << {name: line[:location]} unless result.any? {|e| e.values.include?(line[:location])}
      result
    end
  end
end

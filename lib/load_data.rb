require 'csv'

module LoadData
  extend self

  def load_data(file_hash)
    file_name = file_hash[:enrollment][:kindergarten]
    loaded_data = csv_parse(file_name)
    compile_names(loaded_data)
  end

  def csv_parse(file_name)
    CSV.open file_name, headers: true, header_converters: :symbol
  end

  def compile_names(file_content)
    file_content.reduce([]) do |result, line|
      result << {name: line[:location], kindergarten_participation: Hash.new} unless result.any? {|e| e.values.include?(line[:location])}
      current_enrollment = result.detect { |h| h.values.include?(line[:location])}
      current_enrollment[:kindergarten_participation][line[:timeframe].to_i] = line[:data].to_f
      result
    end
  end
end

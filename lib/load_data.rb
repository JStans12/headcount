require 'csv'
require 'pry'

module LoadData
  extend self

  def load_data(file_name)
    loaded_data = csv_parse(file_name[1])
    return compile_names(loaded_data, :kindergarten_participation) if file_name[0] == :kindergarten
    return compile_names(loaded_data, :high_school_graduation) if file_name[0] == :high_school_graduation
  end

  def csv_parse(file_name)
    CSV.open file_name, headers: true, header_converters: :symbol
  end

  def compile_names(file_content, enrollment_type)
    file_content.reduce([]) do |result, line|
      unless result.any? {|e| e.values.include?(line[:location])}
        result << {name: line[:location], enrollment_type => Hash.new}
      end
      current_enrollment = result.detect do |h| # finds / retrieves
        h.values.include?(line[:location])
      end
      current_enrollment[enrollment_type][line[:timeframe].to_i] = line[:data].to_f
      result

      # district stored already?
      # puts data together / packaging / assembling district data / prepackage
      # adding that set of district data to our collection
      #




    end
  end

end

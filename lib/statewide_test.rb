
require 'pry'

class StatewideTest
  attr_reader :name, :data

  def initialize(data)
    @name = data[:name]
    assign_data(data)
  end

  def assign_data(data)
    data_name = data.keys[1]
    @data = {data_name => data[data_name]}
  end

  def proficient_by_data(grade)
    binding.pry
    return @data[:third_grade] if grade == 3
    return @data[:eighth_grade] if grade == 8
  end

  def proficient_by_race_or_ethnicity(race)
    return
  end

end

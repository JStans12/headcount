class Enrollment
  attr_accessor :name, :data

  def initialize(data)
    @name = data[:name]
    assign_data(data)
  end

  def kindergarten_participation_by_year
    @data[:kindergarten_participation]
  end

  def kindergarten_participation_in_year(year)
    @data[:kindergarten_participation][year]
  end

  def assign_data(data)
    data_name = data.keys[1]
    @data = {data_name => data[data_name]}
  end

  def graduation_rate_by_year
    @data[:high_school_graduation]
  end

  def graduation_rate_in_year(year)
    @data[:high_school_graduation][year]
  end
end

class Enrollment
  attr_reader :name, :data

  def initialize(data)
    @name = data[:name]
    @data = {:kindergarten_participation => data[:kindergarten_participation]}

  end

  def kindergarten_participation_by_year
    @data[:kindergarten_participation]
  end

  def kindergarten_participation_in_year(year)
    @data[:kindergarten_participation][year]
  end
end

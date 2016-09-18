class District
  attr_reader :name
  attr_accessor :enrollment, :statewide_test, :economic

  def initialize(name)
    @name = name[:name]
  end

end

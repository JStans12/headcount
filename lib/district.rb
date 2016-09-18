class District
  attr_reader :name
  attr_accessor :enrollment, :statewide_test

  def initialize(name)
    @name = name[:name]
  end

end

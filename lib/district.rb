class District
  attr_reader :name
  attr_accessor :enrollment

  def initialize(name)
    @name = name[:name]
  end

end

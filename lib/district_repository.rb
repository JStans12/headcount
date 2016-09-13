class DistrictRepository
  attr_reader :districts

  def initialize
    @districts = {}
  end

  def find_by_name(name)
    @districts[name.to_sym]
  end

end

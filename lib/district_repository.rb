require './lib/load_data'

class DistrictRepository
  attr_reader :districts

  def initialize
    @districts = {}
  end

  def find_by_name(name)
    @districts[name.to_sym]
  end

  def create_district_objects(compiled_names)
    compiled_names.each do |name|

    end
  end

end

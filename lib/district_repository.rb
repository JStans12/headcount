require './lib/load_data'
require './lib/district'

class DistrictRepository
  include LoadData
  attr_reader :districts

  def initialize
    @districts = {}
  end

  def find_by_name(name)
    @districts[name.to_sym]
  end

  def find_all_matching(name_snip)
    @districts.select do |d|
      d.include?(name_snip)
    end
  end

  def load_data(file_hash)
    compiled_names = LoadData.load_data_district(file_hash)
    create_district_objects(compiled_names)
  end

  def create_district_objects(compiled_names)
    compiled_names.each do |name|
      @districts[name[:name]] = District.new(name)
    end
  end

end

require_relative '../lib/statewide_test'
require_relative '../lib/load_data'
require 'pry'


class StatewideTestRepository
  include LoadData
  attr_reader :statewide

  def initialize
    @statewide = {}
  end

  def find_by_name(name)
    @statewide[name]
  end

  def load_data(file_hash)
    find_file_names(file_hash).each do |file_name|
      all_districts = LoadData.load_data(file_name)
      assign_statewide_objects(all_districts)
    end
  end

  def assign_statewide_objects(all_districts)
    all_districts.each do |current_district|
      add_to_statewide_repository(current_district) if @statewide[current_district[:name]]
      create_statewide_test_objects(current_district) unless @statewide[current_district[:name]]
    end
  end

  def add_to_statewide_repository(current_district)
    existing_statewide = @statewide.find { |statewide| statewide[1].name == current_district[:name] }
    current_district.each { |statewide_key, statewide_data| existing_statewide[1].data[statewide_key] = statewide_data unless statewide_key == :name }
  end

  def find_file_names(file_hash)
    file_hash.reduce([]) { |r,(k,v)| v.to_a.map { |f| f.unshift(k) } }
  end

  def create_statewide_test_objects(current_district)
      @statewide[current_district[:name]] = StatewideTest.new(current_district)
  end
end

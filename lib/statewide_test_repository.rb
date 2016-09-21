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

  def load_data(files_by_type)
    find_file_names(files_by_type).each do |file_name|
      all_districts = LoadData.load_data(file_name)
      assign_statewide_objects(all_districts)
    end
  end

  def find_file_names(files_by_type)
    files_by_type.reduce([]) do |files, (file_type, file)|
      file.to_a.map { |file_name| file_name.unshift(file_type) }
    end
  end

  def assign_statewide_objects(all_districts)
    all_districts.each do |current_district|

      if @statewide[current_district[:name]]
        add_to_statewide_repository(current_district)
      end

      unless @statewide[current_district[:name]]
        create_statewide_test_objects(current_district)
      end
    end
  end

  def add_to_statewide_repository(current_district)
    existing_statewide = @statewide.find do |statewide|
      statewide[1].name == current_district[:name]
    end

    current_district.each do |statewide_key, statewide_data|

      unless statewide_key == :name
        existing_statewide[1].data[statewide_key] = statewide_data
      end

    end
  end

  def create_statewide_test_objects(current_district)
      @statewide[current_district[:name]] = StatewideTest.new(current_district)
  end
end

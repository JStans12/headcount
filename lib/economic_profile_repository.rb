require_relative '../lib/economic_profile'
require_relative '../lib/load_data'

class EconomicProfileRepository
  attr_reader :economic_profiles

  def initialize
    @economic_profiles = {}
  end

  def find_by_name(name)
    @economic_profiles[name]
  end

  def load_data(files_by_type)
    find_file_names(files_by_type).each do |file_name|
      unique_districts = LoadData.load_data(file_name)
      assign_economic_profile_objects(unique_districts)
    end
  end

  def find_file_names(files_by_type)
    files_by_type.reduce([]) do |files, (file_type, file)|
      file.to_a.map { |file_name| file_name.unshift(file_type) }
    end
  end

  def assign_economic_profile_objects(unique_districts)
    unique_districts.each do |current_economic_profile|
      if @economic_profiles[current_economic_profile[:name]]
        add_to_economic_profiles(current_economic_profile)
      end
      unless @economic_profiles[current_economic_profile[:name]]
        create_economic_profile_object(current_economic_profile)
      end
    end
  end

  def add_to_economic_profiles(current_economic_profile)
      existing_economic_profile = @economic_profiles.find do |econ_prof|
        econ_prof[1].name == current_economic_profile[:name]
      end
      current_economic_profile.each do |econ_prof_key, econ_prof_data|
        unless econ_prof_key == :name
          existing_economic_profile[1].data[econ_prof_key] = econ_prof_data
        end
      end
  end

  def create_economic_profile_object(current_economic_profile)
    @economic_profiles[current_economic_profile[:name]] =
      EconomicProfile.new(current_economic_profile)
  end
end

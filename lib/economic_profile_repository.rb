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

  def load_data(file_hash)
    find_file_names(file_hash).each do |file_name|
      compiled_names = LoadData.load_data(file_name)
      assign_economic_profile_objects(compiled_names)
    end
    binding.pry
  end

  def find_file_names(file_hash)
    file_hash.reduce([]) { |files,(k,v)| v.to_a.map { |f| f.unshift(k) } }
  end

  def assign_economic_profile_objects(compiled_names)
    compiled_names.each do |current_economic_profile|
      add_to_economic_profiles(current_economic_profile) if @economic_profiles[current_economic_profile[:name]]
      create_economic_profile_object(current_economic_profile) unless @economic_profiles[current_economic_profile[:name]]
    end
  end

  def create_economic_profile_object(current_economic_profile)
    @economic_profiles[current_economic_profile[:name]] = EconomicProfile.new(current_economic_profile)
  end

  def add_to_economic_profiles(current_economic_profile)
      existing_economic_profile = @economic_profiles.find { |economic_profile| economic_profile[1].name == current_economic_profile[:name] }
      current_economic_profile.each { |economic_profile_key, economic_profile_data| existing_economic_profile[1].data[economic_profile_key] = economic_profile_data unless economic_profile_key == :name }
  end
end

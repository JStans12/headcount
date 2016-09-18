require_relative '../lib/load_data'
require_relative '../lib/district'
require_relative '../lib/enrollment_repository'
require_relative '../lib/statewide_test_repository'
require_relative '../lib/economic_profile_repository'

class DistrictRepository
  include LoadData
  attr_reader :districts, :enrollment_repository, :statewide_repository, :economic_repository

  def initialize
    @districts = {}
  end

  def find_by_name(name)
    @districts[name]
  end

  def find_all_matching(name_snip)
    @districts.select { |district| district.include?(name_snip) }
  end

  def load_data(files_by_type)
    find_file_names_with_type(files_by_type).each do |file_name_with_type|
      unique_districts = LoadData.load_data(file_name_with_type.flatten)
      create_district_objects(unique_districts)
      load_for_enrollment(files_by_type, unique_districts) if primary_file_type(:enrollment, file_name_with_type)
      load_for_statewide(files_by_type, unique_districts) if primary_file_type(:statewide_testing, file_name_with_type)
      load_for_economic(files_by_type, unique_districts) if primary_file_type(:economic_profile, file_name_with_type)
    end
  end

  def find_file_names_with_type(files_by_type)
    files_by_type.reduce([]) do |result, (file_type, file_name)|
      result << file_name.to_a.map { |file| file.unshift(file_type) }
      result
    end
  end

  def create_district_objects(unique_districts)
    unique_districts.each do |name|
      @districts[name[:name]] = District.new(name) unless @districts[name[:name]]
    end
  end

  def primary_file_type(primary_type, file_name_with_type)
    file_name_with_type.flatten[0] == primary_type
  end

  def link_statewide_to_districts
    @districts.each do |district_name, district_object|
      district_object.statewide_test = @statewide_repository.statewide.find do |statewide_name, statewide_object|
        district_name == statewide_name
      end[1]
    end
  end

  def link_economic_to_districts
    @districts.each do |district_name, district_object|
      district_object.economic = @economic_repository.economic_profiles.find do |economic_profile_name, economic_profile_object|
        district_name == economic_profile_name
      end[1]
    end
  end

  def link_enrollments_to_districts
    @districts.each do |district_name, district_object|
      district_object.enrollment = @enrollment_repository.enrollments.find do |enrollment_name, enrollment_object|
        district_name == enrollment_name
      end[1]
    end
  end

  def load_for_enrollment(files_by_type, unique_districts)
    build_enrollment_repository(files_by_type.select { |primary_file_type, file| primary_file_type == :enrollment })
    link_enrollments_to_districts
  end

  def load_for_statewide(files_by_type, unique_districts)
    build_statwide_repository(files_by_type.select { |primary_file_type, file| primary_file_type == :statewide_testing })
    link_statewide_to_districts
  end

  def load_for_economic(files_by_type, unique_districts)
    build_economic_repository(files_by_type.select { |primary_file_type, file| primary_file_type == :economic_profile })
    link_economic_to_districts
  end

  def build_enrollment_repository(files_by_type)
    @enrollment_repository = EnrollmentRepository.new
    @enrollment_repository.load_data(files_by_type)
  end

  def build_statwide_repository(files_by_type)
    @statewide_repository = StatewideTestRepository.new
    @statewide_repository.load_data(files_by_type)
  end

  def build_economic_repository(files_by_type)
    @economic_repository = EconomicProfileRepository.new
    @economic_repository.load_data(files_by_type)
  end

end

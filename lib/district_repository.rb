require_relative '../lib/load_data'
require_relative '../lib/district'
require_relative '../lib/enrollment_repository'
require_relative '../lib/statewide_test_repository'
require_relative '../lib/economic_profile_repository'

class DistrictRepository
  include LoadData
  attr_reader :districts, :enrollment_repository, :statewide_repository,
              :economic_repository

  def initialize
    @districts = {}
    @economic_repository = nil
    @enrollment_repository = nil
    @statewide_repository = nil
  end

  def find_by_name(name)
    @districts[name]
  end

  def find_all_matching(name_snip)
    @districts.select { |district| district.include?(name_snip) }
  end

  def load_data(files_by_type)
    find_file_names_with_type(files_by_type).each do |file_name_with_type|
      uniq_districts = LoadData.load_data(file_name_with_type.flatten)
      create_district_objects(uniq_districts)
      load_correct_repo(files_by_type, uniq_districts, file_name_with_type)
    end
  end

  def load_correct_repo(files_by_type, uniq_districts, file_name_with_type)
    if primary_file_type(:enrollment, file_name_with_type)
      load_for_enrollment(files_by_type, uniq_districts)
    end

    if primary_file_type(:statewide_testing, file_name_with_type)
      load_for_statewide(files_by_type, uniq_districts)
    end

    if primary_file_type(:economic_profile, file_name_with_type)
      load_for_economic(files_by_type, uniq_districts)
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
      unless @districts[name[:name]]
        @districts[name[:name]] = District.new(name)
      end
    end
  end

  def primary_file_type(primary_type, file_name_with_type)
    file_name_with_type.flatten[0] == primary_type
  end

  def link_statewide_to_districts
    @districts.each do |district_name, district_object|
      connect_statewide_to_districts(district_name, district_object)
    end
  end

  def connect_statewide_to_districts(district_name, district_object)
    district_object.statewide_test =
    @statewide_repository.statewide.find do |statewide_name, statewide_object|
      district_name == statewide_name
    end[1]
  end

  def link_economic_to_districts
    @districts.each do |district_name, district_object|
      connect_economic_to_districts(district_name, district_object)
    end
  end

  def connect_economic_to_districts(district_name, district_object)
    district_object.economic =
    @economic_repository.economic_profiles.find do |e_prof_name, e_prof_object|
      district_name == e_prof_name
    end[1]
  end

  def link_enrollments_to_districts
    @districts.each do |district_name, district_object|
      connect_enrollments_to_districts(district_name, district_object)
    end
  end

  def connect_enrollments_to_districts(district_name, district_object)
    district_object.enrollment =
     @enrollment_repository.enrollments.find do |enroll_name, enroll_obj|
      district_name == enroll_name
    end[1]
  end

  def load_for_enrollment(files_by_type, unique_districts)
    enrollment_files = files_by_type.select do |primary_file_type, file|
      primary_file_type == :enrollment
    end

    build_enrollment_repository(enrollment_files)
    link_enrollments_to_districts
  end

  def load_for_statewide(files_by_type, unique_districts)
    statewide_files = files_by_type.select do |primary_file_type, file|
      primary_file_type == :statewide_testing
    end

    build_statwide_repository(statewide_files)
    link_statewide_to_districts
  end

  def load_for_economic(files_by_type, unique_districts)
    economic_files = files_by_type.select do |primary_file_type, file|
      primary_file_type == :economic_profile
    end

    build_economic_repository(economic_files)
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

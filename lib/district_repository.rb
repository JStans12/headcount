require_relative '../lib/load_data'
require_relative '../lib/district'
require_relative '../lib/enrollment_repository'

class DistrictRepository
  include LoadData
  attr_reader :districts, :enrollment_repository

  def initialize
    @districts = {}
  end

  def find_by_name(name)
    @districts[name]
  end

  def find_all_matching(name_snip)
    @districts.select { |d| d.include?(name_snip) }
  end

  def load_data(file_hash)
    compiled_names = LoadData.load_data(file_hash)
    create_district_objects(compiled_names)
    build_enrollment_repository(file_hash)
    link_enrollments_to_districts
  end

  def create_district_objects(compiled_names)
    compiled_names.each do |name|
      @districts[name[:name]] = District.new(name)
    end
  end

  def build_enrollment_repository(file_hash)
    @enrollment_repository = EnrollmentRepository.new
    @enrollment_repository.load_data(file_hash)
  end

  def link_enrollments_to_districts
    @districts.each do |dname, dobject|
      dobject.enrollment = @enrollment_repository.enrollments.find { |ekey, evalue| dname = ekey }[1]
    end
  end

end

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
    find_file_names(file_hash).each do |file_name|
      compiled_names = LoadData.load_data(file_name.flatten)
      load_for_enrollment(file_hash, compiled_names) if file_name.flatten[0] == :enrollment
    end
  end

  def load_for_enrollment(file_hash, compiled_names)
    create_district_objects(compiled_names)
    build_enrollment_repository(file_hash)
    link_enrollments_to_districts
  end

  def find_file_names(file_hash)
    file_hash.reduce([]) { |r,(k,v)| r << v.to_a.map { |f| f.unshift(k) } ;r }
  end

  def create_district_objects(compiled_names)
    compiled_names.each do |name|
      @districts[name[:name]] = District.new(name) unless @districts[name[:name]]
    end
  end

  def build_enrollment_repository(file_hash)
    @enrollment_repository = EnrollmentRepository.new
    @enrollment_repository.load_data(file_hash)
  end

  def link_enrollments_to_districts
    @districts.each do |district_name, district_object|
      district_object.enrollment = @enrollment_repository.enrollments.find { |enrollment_name, enrollment_object| district_name == enrollment_name }[1]
    end
  end

end

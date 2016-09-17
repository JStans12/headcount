require_relative '../lib/enrollment'
require_relative '../lib/load_data'
require 'pry'

class EnrollmentRepository
  include LoadData
    attr_reader :enrollments

  def initialize
    @enrollments = {}
  end

  def find_by_name(name)
    @enrollments[name]
  end

  def load_data(file_hash)
    find_file_names(file_hash).each do |file_name|
      compiled_names = LoadData.load_data(file_name)
      assign_enrollment_objects(compiled_names)
    end
  end

  def find_file_names(file_hash)
    file_hash.reduce([]) { |r,(k,v)| v.to_a.map { |f| f.unshift(k) } }
  end

  def assign_enrollment_objects(compiled_names)
    compiled_names.each do |current_enrollment|
      add_to_enrollments(current_enrollment) if @enrollments[current_enrollment[:name]]
      create_enrollment_object(current_enrollment) unless @enrollments[current_enrollment[:name]]
    end
  end

  def create_enrollment_object(current_enrollment)
    @enrollments[current_enrollment[:name]] = Enrollment.new(current_enrollment)
  end

  def add_to_enrollments(current_enrollment)
      existing_enrollment = @enrollments.find { |enrollment| enrollment[1].name == current_enrollment[:name] }
      current_enrollment.each { |enrollment_key, enrollment_data| existing_enrollment[1].data[enrollment_key] = enrollment_data unless enrollment_key == :name }
  end

end

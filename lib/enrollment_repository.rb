require_relative '../lib/enrollment'
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
    file_names = find_file_names(file_hash)
    file_names.each do |file_name|
      compiled_names = LoadData.load_data(file_name)
      create_enrollment_objects(compiled_names)
    end
  end

  def find_file_names(file_hash)
    file_hash[:enrollment].to_a
  end

  def create_enrollment_objects(compiled_names)
    compiled_names.each do |current_enrollment|
      add_to_enrollments(compiled_names) if @enrollments[current_enrollment[:name]]
      @enrollments[current_enrollment[:name]] = Enrollment.new(current_enrollment) unless @enrollments[current_enrollment[:name]]
    end
  end

  def add_to_enrollments(compiled_names)
    compiled_names.each do |current_enrollment|
      existing_enrollment = @enrollments.find do |e|
         e[1].name == current_enrollment[:name]
       end
      current_enrollment.each do |k,v|
        existing_enrollment[1].data[k] = v unless k == :name
      end
    end
  end

end

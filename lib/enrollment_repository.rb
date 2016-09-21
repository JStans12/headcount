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

  def load_data(files_by_type)
    find_file_names(files_by_type).each do |file_name|
      unique_districts = LoadData.load_data(file_name)
      assign_enrollment_objects(unique_districts)
    end
  end

  def find_file_names(files_by_type)
    files_by_type.reduce([]) do |files, (file_type, file)|
      file.to_a.map { |file_name| file_name.unshift(file_type) }
    end
  end

  def assign_enrollment_objects(unique_districts)
    unique_districts.each do |current_enrollment|
      if @enrollments[current_enrollment[:name]]
        add_to_enrollments(current_enrollment)
      end
      unless @enrollments[current_enrollment[:name]]
        create_enrollment_object(current_enrollment)
      end
    end
  end

  def add_to_enrollments(current_enrollment)
      existing_enrollment = @enrollments.find do |enrollment|
        enrollment[1].name == current_enrollment[:name]
      end
      current_enrollment.each do |enrollment_key, enrollment_data|
        unless enrollment_key == :name
        existing_enrollment[1].data[enrollment_key] = enrollment_data
        end
      end
  end

  def create_enrollment_object(current_enrollment)
    @enrollments[current_enrollment[:name]] = Enrollment.new(current_enrollment)
  end
end

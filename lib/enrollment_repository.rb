require './lib/enrollment'
class EnrollmentRepository
  include LoadData
    attr_reader :enrollments

  def initialize
    @enrollments = {}
  end

  def find_by_name(name)
    @enrollments[name.to_sym]
  end

  def load_data(file_hash)
    compiled_names = LoadData.load_data_enrollment(file_hash)
    create_enrollment_objects(compiled_names)
  end

  def create_enrollment_objects(compiled_names)
    compiled_names.each do |current_enrollment|
      @enrollments[current_enrollment[:name]] = Enrollment.new(current_enrollment)
    end
  end

end

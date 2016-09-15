class StatewideTestRepository
  def find_by_name(name)
    @enrollments[name]
  end

  def load_data(file_hash)
    find_file_names(file_hash).each do |file_name|
      compiled_names = LoadData.load_data(file_name)
      assign_enrollment_objects(compiled_names)
    end
  end

  
end

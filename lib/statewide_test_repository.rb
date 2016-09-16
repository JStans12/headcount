class StatewideTestRepository
  def find_by_name(name)
    @enrollments[name]
  end

  def load_data(file_hash)
    find_file_names(file_hash).each do |file_name|
      compiled_names = LoadData.load_data(file_name)
      create_statewide_test_objects(compiled_names)
    end
  end

  def find_file_names(file_hash)
    file_hash.reduce([]) { |r,(k,v)| v.to_a.map { |f| f.unshift(k) } }
  end

  def create_statewide_test_objects(compiled_names)

  end
end

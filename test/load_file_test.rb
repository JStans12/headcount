require 'minitest/autorun'
require 'minitest/pride'
require './lib/district_repository'
require './lib/load_data'

class TestLoadData < Minitest::Test
  include LoadData

  def test_file_name_returns_file_name

      assert_equal 181, load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}}).length
  end

  def test_csv_file_loaded_into_program

    assert_equal Array, csv_parse("./data/Kindergarteners test file.csv").class
  end

  def test_compile_names_creates_array_of_name_hashes

    assert_equal 3, csv_parse("./data/Kindergarteners test file.csv").length
  end

  def test_district_objects_are_created
    dr = DistrictRepository.new

    assert_equal 3, dr.districts.length
  end
end

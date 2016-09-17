require './test_helper'
require './lib/load_data'

class TestLoadData < Minitest::Test
  include LoadData

  def test_file_name_returns_file_name

      assert_equal 181, load_data([:enrollment, :kindergarten, "./data/Kindergartners in full-day program.csv"]).length
  end

  def test_csv_file_loaded_into_program

    assert_equal CSV, csv_parse("./test/fixtures/Kindergarteners test file.csv").class
  end

  def test_array_is_loaded_with_hash_objects
    array_of_enrollments = compile_names_enrollment(csv_parse("./test/fixtures/Kindergarteners test file.csv"), :kindergarten_participation)

    assert_equal 0.38456, array_of_enrollments[0][:kindergarten_participation][2008]
  end

  def test_load_data_can_load_a_third_grade_file

    loaded_data = LoadData.load_data([:statewide_testing, :third_grade, './test/fixtures/third grade students score fix.csv'])

    assert_equal 3, loaded_data.length
  end
end

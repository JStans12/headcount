require './test_helper'
require './lib/load_data'

class TestLoadData < Minitest::Test
  include LoadData

  def test_file_name_returns_file_name

      assert_equal 181, load_data([:enrollment, :kindergarten, "./data/Kindergartners in full-day program.csv"]).length
  end

  def test_csv_file_loaded_into_program_mapped_to_array

    assert_equal Array, csv_parse(["type", "sub-type", "./test/fixtures/Kindergarteners test file.csv"]).class
  end

  def test_array_is_loaded_with_hash_objects_enrollment
    array_of_enrollments = compile_enrollment(csv_parse(["type", "sub-type", "./test/fixtures/Kindergarteners test file.csv"]), :kindergarten_participation)

    assert_equal 0.38456, array_of_enrollments[0][:kindergarten_participation][2008]
  end

  def test_load_data_can_load_a_third_grade_file
    loaded_data = LoadData.load_data([:statewide_testing, :third_grade, './test/fixtures/third grade students score fix.csv'])

    assert_equal 3, loaded_data.length
  end

  def test_array_is_loaded_with_hash_objects_statewide_grade
    array_of_statewide = compile_statewide_grade(csv_parse([:statewide_testing, :third_grade, './test/fixtures/third grade students score fix.csv']), :third_grade)

    assert_equal 0.715, array_of_statewide[0][:third_grade][2014][:math]
  end

  def test_load_data_can_load_an_ethnicity_file
    loaded_data = LoadData.load_data([:statewide_testing, :math, "./test/fixtures/average proficiency math.csv"])

    assert_equal 4, loaded_data.length
  end

  def test_array_is_loaded_with_hash_objects_statewide_ethnicity
    array_of_statewide = compile_statewide_subject(csv_parse([:statewide_testing, :math, "./test/fixtures/average proficiency math.csv"]), :math)

    assert_equal 0.709, array_of_statewide[0][:math][:asian][2011]
  end

  def test_load_data_can_load_economic_profile
    loaded_data = LoadData.load_data([:economic_profile, :median_household_income, "./test/fixtures/median_household_income.csv"])

    assert_equal 4, loaded_data.length
  end

  def test_array_is_loaded_with_hash_objects_economic_profiles
    array_of_economic_profile = compile_economic_profile(csv_parse([:economic_profile, :median_household_income, "./test/fixtures/median_household_income.csv"]), :median_household_income)

    assert_equal 56456.0, array_of_economic_profile[0][:median_household_income][[2006, 2010]]
  end

  def test_load_data_can_load_free_lunch_data
    loaded_data = LoadData.load_data([:economic_profile, :free_or_reduced_price_lunch, "./test/fixtures/free_or_reduced_price_lunch.csv"])

    assert_equal 4, loaded_data.length
  end

  def test_array_is_loaded_with_hash_objects_free_lunch
    array_of_economic_profile = compile_economic_profile(csv_parse([:economic_profile, :free_or_reduced_price_lunch, "./test/fixtures/free_or_reduced_price_lunch.csv"]), :free_or_reduced_price_lunch)

    assert_equal 195149, array_of_economic_profile[0][:free_or_reduced_price_lunch][2000]
  end
end

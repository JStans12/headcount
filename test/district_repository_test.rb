require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/district_repository'
require_relative '../lib/district'

class TestDistrictRepo < Minitest::Test

  def test_inits_with_empty_districts_hash
    dr = DistrictRepository.new
    assert_equal ({}), dr.districts
  end

  def test_find_by_name_finds_district
    dr = DistrictRepository.new
    dr.districts["ACADEMY 20"] = District.new({:name => "ACADEMY 20"})

    assert_equal District, dr.find_by_name("ACADEMY 20").class
    assert_equal "ACADEMY 20", dr.find_by_name("ACADEMY 20").name
  end

  def test_load_data_creates_district_objects
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file.csv"}})

    assert_equal 3, dr.districts.length
  end

  def test_find_all_matching
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file.csv"}})

    assert_equal 3, dr.find_all_matching("AD").length
    assert_equal 1, dr.find_all_matching("AC").length
  end

end

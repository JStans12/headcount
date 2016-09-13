require 'minitest/autorun'
require 'minitest/pride'
require './lib/district_repository'
require './lib/district'

class TestDistrictRepo < Minitest::Test

  def test_inits_with_empty_districts_hash
    dr = DistrictRepository.new
    assert_equal ({}), dr.districts
  end

  def test_find_by_name_finds_district
    dr = DistrictRepository.new
    dr.districts["ACADEMY 20".to_sym] = District.new({:name => "ACADEMY 20"})

    assert_equal District, dr.find_by_name("ACADEMY 20").class
    assert_equal "ACADEMY 20", dr.find_by_name("ACADEMY 20").name
  end

end

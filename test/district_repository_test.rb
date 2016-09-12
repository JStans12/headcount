require 'minitest/autorun'
require 'minitest/pride'
require './lib/district_repository'

class TestDistrictRepo < Minitest::Test

  def test_inits_with_empty_districts_hash
    dr = DistrictRepository.new
    assert_equal ({}), dr.districts
  end

end

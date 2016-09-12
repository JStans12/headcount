require 'minitest/autorun'
require 'minitest/pride'
require './lib/district_repository'
require './lib/district'

class TestDistrict < Minitest::Test

  def test_can_init
    d = District.new({:name => "ACADEMY 20"})
    assert_equal "ACADEMY 20", d.name
  end

end

require 'minitest/autorun'
require 'minitest/pride'
require './lib/district_repository'
require './lib/enrollment'

class TestEnrollment < Minitest::Test
  def test_enrollment_is_initialized_with_name
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    assert_equal "ACADEMY 20", e.name
  end

  def test_data_loads_properly
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})

    assert_equal ({:kindergarten_participation=>{2010=>0.3915, 2011=>0.35356, 2012=>0.2677}}), e.data
  end

  def test_can_find_kindergarten_participation_by_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})

    assert_equal ({2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}), e.kindergarten_participation_by_year
  end

  def test_can_find_kindergarten_participation_in_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})

    assert_equal 0.3915, e.kindergarten_participation_in_year(2010)
  end
end

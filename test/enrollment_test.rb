require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/enrollment'

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

  def test_enrollment_can_find_graduation_rate_by_year
    er = EnrollmentRepository.new
    er.load_data({
                   :enrollment => {
                     :kindergarten => "./test/fixtures/Kindergarteners test file2.csv",
                     :high_school_graduation => "./test/fixtures/Highschool grad test file2.csv"
                   }
                 })
    e = er.find_by_name("ADAMS-ARAPAHOE 28J")


    expected = {2010=>0.455, 2011=>0.485, 2012=>0.47984, 2013=>0.52627, 2014=>0.559}
    expected.each do |k,v|
      assert_in_delta v, e.graduation_rate_by_year[k], 0.005
    end
    assert_in_delta 0.455, e.graduation_rate_in_year(2010), 0.005
  end
end

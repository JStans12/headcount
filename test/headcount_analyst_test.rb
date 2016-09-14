require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/headcount_analyst'
require_relative '../lib/district_repository'
# require_relative '../lib/district'
require_relative '../lib/enrollment_repository'
require_relative '../lib/enrollment'

class TestHeadCountAnalyst < Minitest::Test
  def setup
    disr = DistrictRepository.new
    disr.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file.csv"}})
  end

  def test_calculates_average_participation
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file.csv"}})
    ha = HeadcountAnalyst.new(dr)
    district = dr.find_by_name("ACADEMY 20")

    assert_equal 0.4064509090909091, ha.find_average_participation(district)
  end

  def test_can_compare_participation_with_state_participation
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file2.csv"}})
    ha = HeadcountAnalyst.new(dr)

    assert_equal 0.7663193545788461, ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'Colorado')
  end

  def test_can_compare_participation_with_district_participation
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    ha = HeadcountAnalyst.new(dr)

    assert_equal 0.447096, ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1')
  end

  def test_kindergarten_participation_rate_variation_trend
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    ha = HeadcountAnalyst.new(dr)

    assert_equal 1.2576413758640794, ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'Colorado')[2004]
  end

end

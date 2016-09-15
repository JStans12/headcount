require 'simplecov'
SimpleCov.start
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

    assert_equal 0.4064509090909091, ha.find_average_participation(district, :kindergarten_participation)
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

  def test_can_compare_kindergarten_participation_against_highschool_graduation_by_district
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
                                  :high_school_graduation => "./data/High school graduation rates.csv"}})
    ha = HeadcountAnalyst.new(dr)

    assert_equal 0.5485413176167342, ha.kindergarten_participation_against_high_school_graduation('MONTROSE COUNTY RE-1J')
    assert_equal 0.8005516618636318, ha.kindergarten_participation_against_high_school_graduation('STEAMBOAT SPRINGS RE-2')
  end

  def test_participation_correlation_returns_true_or_false_depending_on_correlation
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
                                  :high_school_graduation => "./data/High school graduation rates.csv"}})
    ha = HeadcountAnalyst.new(dr)

    refute ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'MONTROSE COUNTY RE-1J')
    assert ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'STEAMBOAT SPRINGS RE-2')
  end

  def test_statewide_kindergarten_high_school_prediction
   dr = DistrictRepository.new
   dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
                                 :high_school_graduation => "./data/High school graduation rates.csv"}})
   ha = HeadcountAnalyst.new(dr)

   refute ha.kindergarten_participation_correlates_with_high_school_graduation(:for => 'STATEWIDE')
 end

 def test_multiple_districts_participation_can_be_correlated
   dr = DistrictRepository.new
   dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
                                 :high_school_graduation => "./data/High school graduation rates.csv"}})
   ha = HeadcountAnalyst.new(dr)
   districts = ["ACADEMY 20", 'PARK (ESTES PARK) R-3', 'YUMA SCHOOL DISTRICT 1']
   assert ha.kindergarten_participation_correlates_with_high_school_graduation(:across => districts)
 end
end

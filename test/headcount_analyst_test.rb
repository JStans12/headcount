require './test_helper'
require './lib/headcount_analyst'
require './lib/district_repository'

class TestHeadCountAnalyst < Minitest::Test
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
    dr.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file2.csv"}})
    ha = HeadcountAnalyst.new(dr)

    assert_equal 0.6189739145362568, ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'ADAMS-ARAPAHOE 28J')
  end

  def test_kindergarten_participation_rate_variation_trend
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file2.csv"}})
    ha = HeadcountAnalyst.new(dr)

    assert_equal 1.2576413758640794, ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'Colorado')[2004]
  end

  def test_can_compare_kindergarten_participation_against_highschool_graduation_by_district
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file2.csv",
                                  :high_school_graduation => "./test/fixtures/Highschool grad test file.csv"}})
    ha = HeadcountAnalyst.new(dr)

    assert_equal 1.8575042817389098, ha.kindergarten_participation_against_high_school_graduation('ADAMS-ARAPAHOE 28J')
    assert_equal 1.6396968634399158, ha.kindergarten_participation_against_high_school_graduation('ADAMS COUNTY 14')
  end

  def test_participation_correlation_returns_true_or_false_depending_on_correlation
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file2.csv",
                                  :high_school_graduation => "./test/fixtures/Highschool grad test file.csv"}})
    ha = HeadcountAnalyst.new(dr)

    refute ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'ADAMS-ARAPAHOE 28J')
    assert ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20')
  end

  def test_statewide_kindergarten_high_school_prediction
   dr = DistrictRepository.new
   dr.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file2.csv",
                                 :high_school_graduation => "./test/fixtures/Highschool grad test file2.csv"}})
   ha = HeadcountAnalyst.new(dr)

   refute ha.kindergarten_participation_correlates_with_high_school_graduation(:for => 'STATEWIDE')
  end

 def test_multiple_districts_participation_can_be_correlated
   dr = DistrictRepository.new
   dr.load_data({:enrollment => {:kindergarten => "./test/fixtures/Kindergarteners test file2.csv",
                                 :high_school_graduation => "./test/fixtures/Highschool grad test file2.csv"}})
   ha = HeadcountAnalyst.new(dr)
   districts = ["ACADEMY 20", 'ADAMS COUNTY 14', 'ADAMS-ARAPAHOE 28J']
   refute ha.kindergarten_participation_correlates_with_high_school_graduation(:across => districts)
 end
end

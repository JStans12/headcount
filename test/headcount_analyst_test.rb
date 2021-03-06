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

    assert_equal 0.7663193545788461, ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
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

    assert_equal 1.2576413758640794, ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')[2004]
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

  def test_top_statewide_test_year_raises_insufficient_information_error
    dr = DistrictRepository.new
    dr.load_data({
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv" }})

    ha = HeadcountAnalyst.new(dr)
    assert_raises(InsufficientInformationError) do
       ha.top_statewide_test_year_over_year_growth(subject: :math)
    end
  end

  def test_top_statewide_test_year_finds_top
    dr = DistrictRepository.new
    dr.load_data({
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv" }})

    ha = HeadcountAnalyst.new(dr)

    assert_equal "WILEY RE-13 JT", ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :math).first
    assert_in_delta 0.3, ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :math).last, 0.005

    assert_equal "COTOPAXI RE-3", ha.top_statewide_test_year_over_year_growth(grade: 8, subject: :reading).first
    assert_in_delta 0.13, ha.top_statewide_test_year_over_year_growth(grade: 8, subject: :reading).last, 0.005

    assert_equal "BETHUNE R-5", ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :writing).first
    assert_in_delta 0.148, ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :writing).last, 0.005
  end

  def test_top_statewide_test_year_finds_top_number
    dr = DistrictRepository.new
    dr.load_data({
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv" }})

    ha = HeadcountAnalyst.new(dr)
    expected = [["WILEY RE-13 JT", 0.30000000000000004], ["SANGRE DE CRISTO RE-22J", 0.07133333333333335], ["COTOPAXI RE-3", 0.07000000000000002]]

    assert_equal expected, ha.top_statewide_test_year_over_year_growth(grade: 3, top: 3, subject: :math)
  end

  def test_finding_top_overall_districts
    dr = DistrictRepository.new
    dr.load_data({
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv" }})

    ha = HeadcountAnalyst.new(dr)

    assert_equal "SANGRE DE CRISTO RE-22J", ha.top_statewide_test_year_over_year_growth(grade: 3).first
    assert_in_delta 0.071, ha.top_statewide_test_year_over_year_growth(grade: 3).last, 0.005

    assert_equal "OURAY R-1", ha.top_statewide_test_year_over_year_growth(grade: 8).first
    assert_in_delta 0.11, ha.top_statewide_test_year_over_year_growth(grade: 8).last, 0.005
  end

  def test_weighting_results_by_subject
    dr = DistrictRepository.new
    dr.load_data({
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv" }})

    ha = HeadcountAnalyst.new(dr)

    top_performer = ha.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
    assert_equal "OURAY R-1", top_performer.first
    assert_in_delta 0.153, top_performer.last, 0.005
  end

  def test_we_can_find_top_num_accross_all_districts
    dr = DistrictRepository.new
    dr.load_data({
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv" }})

    ha = HeadcountAnalyst.new(dr)
    expected = [["SANGRE DE CRISTO RE-22J", 0.07133333333333335], ["MANCOS RE-6", 0.07130555555555555], ["OTIS R-3", 0.0675]]

    assert_equal expected, ha.top_statewide_test_year_over_year_growth(grade: 3, top: 3)
  end

end

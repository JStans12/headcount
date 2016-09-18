require './test_helper'
require './lib/statewide_test'
require './lib/statewide_test_repository'


class TestStatewideTest < Minitest::Test

  def test_statewide_test_is_initialized_with_a_name
    st = StatewideTest.new({:name => "ACADEMY 20",
                            :third_grade => { 2011 => {math: 0.816, reading: 0.897, writing: 0.826},
                                              2012 => {math: 0.818, reading: 0.893, writing: 0.808},
                                              2013 => {math: 0.805, reading: 0.901, writing: 0.810},
                                              2014 => {math: 0.800, reading: 0.855, writing: 0.789}
                             }})

    assert_equal "ACADEMY 20", st.name
  end

  def test_statewide_test_is_initialized_with_proper_data
    st = StatewideTest.new({:name => "ACADEMY 20",
                            :third_grade => { 2011 => {math: 0.816, reading: 0.897, writing: 0.826},
                                              2012 => {math: 0.818, reading: 0.893, writing: 0.808},
                                              2013 => {math: 0.805, reading: 0.901, writing: 0.810},
                                              2014 => {math: 0.800, reading: 0.855, writing: 0.789}
                             }})

    expected = {:third_grade => { 2011 => {math: 0.816, reading: 0.897, writing: 0.826},
                                  2012 => {math: 0.818, reading: 0.893, writing: 0.808},
                                  2013 => {math: 0.805, reading: 0.901, writing: 0.810},
                                  2014 => {math: 0.800, reading: 0.855, writing: 0.789}
                             }}

    assert_equal expected, st.data
  end

  def test_statewide_test_can_access_data_by_grades
    str = statewide_repo

    single = str.find_by_name("ACADEMY 20")

    assert_equal 0.64, single.proficient_by_grade(8)[2008][:math]
    assert_raises(UnknownDataError) do
      single.proficient_by_grade(1)
    end
  end

  def test_statewide_test_can_raise_unknown_data_error_for_unknown_race
    str = statewide_repo

    single = str.find_by_name("ACADEMY 20")

    assert_raises(UnknownDataError) do
      single.proficient_by_race_or_ethnicity(:fandango)
    end
  end

  def test_statewide_test_can_access_data_by_race_or_ethnicity
    str = statewide_repo

    single = str.find_by_name("ACADEMY 20")
    expected = {:math=>0.816, :reading=>0.897, :writing=>0.826}

    assert_equal expected, single.proficient_by_race_or_ethnicity(:asian)[2011]
  end

  def test_statewide_test_can_access_data_for_different_ethinicities
    str = statewide_repo

    single = str.find_by_name("ACADEMY 20")
    expected_pi = {:math=>0.568, :reading=>0.745, :writing=>0.725}
    expected_tow = {:math=>0.677, :reading=>0.841, :writing=>0.727}

    assert_equal expected_pi, single.proficient_by_race_or_ethnicity(:pacific_islander)[2011]
    assert_equal expected_tow, single.proficient_by_race_or_ethnicity(:two_or_more)[2011]
  end

  def test_we_can_find_proficiency_by_subject_grade_and_year
    str = full_statewide

    single = str.find_by_name("ACADEMY 20")
    assert_equal 0.857, single.proficient_for_subject_by_grade_in_year(:math, 3, 2008)

    testing = str.find_by_name("PLATEAU VALLEY 50")
    assert_equal "N/A", testing.proficient_for_subject_by_grade_in_year(:reading, 8, 2011)
  end

  def test_we_can_find_proficiency_by_subject_race_and_year
    str = statewide_repo
    single = str.find_by_name("ACADEMY 20")

    assert_equal 0.818, single.proficient_for_subject_by_race_in_year(:math, :asian, 2012)
  end

  def statewide_repo
    str = StatewideTestRepository.new
    str.load_data({
                    :statewide_testing => {
                      :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
                      :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
                      :math => "./test/fixtures/average proficiency math.csv",
                      :reading => "./test/fixtures/average proficiency reading.csv",
                      :writing => "./test/fixtures/average proficiency writing.csv"
                    }
                  })
    str
  end

  def full_statewide
    str = StatewideTestRepository.new
    str.load_data({
                    :statewide_testing => {
                      :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
                      :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
                      :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
                      :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
                      :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
                    }
                  })
    str
  end

end

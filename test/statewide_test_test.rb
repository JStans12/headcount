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

    single = str.find_by_name("ACADEMY 20")

    assert_equal "0.64", single.proficient_by_data(8)["2008"]["Math"]
  end

  def test_statewide_test_can_access_data_by_race_or_ethnicity
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

    single = str.find_by_name("ACADEMY 20")

    assert_equal "0.64", single.proficient_by_data(8)["2008"]["Math"]
  end
end

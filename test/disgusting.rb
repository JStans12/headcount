require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/district_repository'
require_relative '../lib/district'
require_relative '../lib/enrollment_repository'
require_relative '../lib/enrollment'

class TestSomeNastyShit < Minitest::Test

  # dr = DistrictRepository.new
  # skip
  # dr.load_data({
  #   :enrollment => {
  #     :kindergarten => "./data/Kindergartners in full-day program.csv",
  #     :high_school_graduation => "./data/High school graduation rates.csv",
  #   },
  #   :statewide_testing => {
  #     :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
  #     :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
  #     :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
  #     :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
  #     :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
  #   }
  # })

  def test_load_populates_er_with_enrollments_of_kindergarten_and_graduation
    dr = DistrictRepository.new
    dr.load_data({
      :enrollment => {
        :kindergarten => "./data/Kindergartners in full-day program.csv",
        :high_school_graduation => "./data/High school graduation rates.csv"
      }
    })
    assert_equal 0.47883, dr.enrollment_repository.enrollments["ACADEMY 20"].data[:kindergarten_participation][2012]
    assert_equal 0.88983, dr.enrollment_repository.enrollments["ACADEMY 20"].data[:high_school_graduation][2012]
  end

end

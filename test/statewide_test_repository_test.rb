require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/enrollment'
require_relative '../lib/statewide_test_repository'
# require_relative '../test_helper'

class TestStatewideTestRepository < Minitest::Test

  def test_loading_data_to_test_repo_can_load_data
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

    str = str.find_by_name("ACADEMY 20")

    assert_equal 'ACADEMY 20', str.name
  end

end

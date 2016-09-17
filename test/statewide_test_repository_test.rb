require './test_helper'
require './lib/statewide_test_repository'

class TestStatewideTestRepository < Minitest::Test

  def test_loading_data_to_test_repo_can_load_data
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

    str = str.find_by_name("ACADEMY 20")

    assert_equal 'ACADEMY 20', str.name
  end

end

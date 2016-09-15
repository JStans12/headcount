require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/statewide_test'

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
end

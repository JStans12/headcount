require './test_helper'
require './lib/sanitizer'

class TestSanitizer < Minitest::Test
  include Sanitizer

  def test_we_can_clean_timeframes
    assert_equal 2014, Sanitizer.clean_timeframe("2014")
    assert_equal [2009, 2014], Sanitizer.clean_timeframe("2009-2014")
  end

  def test_we_can_clean_data
    assert_equal 50000, Sanitizer.clean_data("50000", [1,:free_or_reduced_price_lunch], {:dataformat => "Number"} )
    assert_equal 1.384, Sanitizer.clean_data("1.3845", [:statewide_testing, :something], {:dataformat => "nothing"} )
    assert_equal 1.384, Sanitizer.clean_data("1.3845", [:something, :free_or_reduced_price_lunch], {:dataformat => "Percent"} )
    assert_equal 1.12, Sanitizer.clean_data("1.12", [1,2,3], {})
  end

  def test_we_can_clean_score
    assert_equal :thing, Sanitizer.clean_score("THING")
  end

  def test_we_can_clean_location
    assert_equal "PLACE", Sanitizer.clean_location("place")
  end

  def test_we_can_clean_whole_lines_lunch_number
    expected = {:timeframe => 2013, :data => 50000, :dataformat => "Number", :location => "PLACE"}
    assert_equal expected, Sanitizer.clean_line({:timeframe => "2013", :data => "50000", :dataformat => "Number", :location => "place"}, [:economic_profile, :free_or_reduced_price_lunch, "file_name"])
  end

  def test_we_can_clean_whole_lines_lunch_percentage
    expected = {:timeframe => 2013, :data => 0.882, :dataformat => "Percent", :location => "PLACE"}
    assert_equal expected, Sanitizer.clean_line({:timeframe => "2013", :data => "0.882734", :dataformat => "Percent", :location => "place"}, [:economic_profile, :free_or_reduced_price_lunch, "file_name"])
  end

  def test_we_can_clean_whole_lines_for_score
    expected = {:score => :math, :timeframe => 2013, :data => 0.882, :location => "PLACE"}
    assert_equal expected, Sanitizer.clean_line({:score => "MaTh", :timeframe => "2013", :data => "0.882", :location => "PLACE"}, "fandango")
  end

  def test_we_can_clean_whole_lines_for_location
    expected = {:score => :math, :timeframe => 2013, :data => 0.882, :location => "COLORADO"}
    assert_equal expected, Sanitizer.clean_line({:score => "MaTh", :timeframe => "2013", :data => "0.882", :location => "colorado"}, "fandango")
  end
end

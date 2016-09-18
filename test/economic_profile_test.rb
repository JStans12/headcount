require './test_helper'
require './lib/economic_profile'
require 'pry'

class TestEconomicProfile < Minitest::Test
  def test_economic_profile_is_initialized_with_name
    e = EconomicProfile.new(economic_data)

    assert_equal "ACADEMY 20", e.name
  end

  def test_economic_data_loads_properly
    e = EconomicProfile.new(economic_data)
    expected = {"ACADEMY 20"=>{:median_household_income=>{[2009, 2015]=>50000, [2013, 2014]=>60000}, :children_in_poverty=>{2012 => 0.1845, 2013 => 0.845, 2014 => 0.145}, :free_or_reduced_price_lunch=>{2014=>{:percentage=>0.023, :total=>100}}, :title_i=>{2015=>0.543}}}

    assert_equal expected, e.data
  end

  def test_can_find_median_household_income_by_year
    e = EconomicProfile.new(economic_data)

    assert_equal 55000, e.median_household_income_in_year(2014)
  end

  def test_returns_unknown_data_error_if_year_does_not_exist
    e = EconomicProfile.new(economic_data)

    assert_raises(UnknownDataError) { e.median_household_income_in_year(1776) }
  end

  def test_can_find_median_household_income_average
    e = EconomicProfile.new(economic_data)

    assert_equal 55000, e.median_household_income_average
  end

  def test_can_find_children_in_poverty_in_a_given_year
    e = EconomicProfile.new(economic_data)

    assert_equal 0.1845, e.children_in_poverty_in_year(2012)
  end

  def test_returns_unknown_data_error_if_children_in_poverty_year_does_not_exist
    e = EconomicProfile.new(economic_data)

    assert_raises(UnknownDataError) { e.children_in_poverty_in_year(1776) }
  end

  def test_can_find_free_or_reduced_price_lunch_percentage_in_year
    e = EconomicProfile.new(economic_data)

    assert_equal 0.023, e.free_or_reduced_price_lunch_percentage_in_year(2014)
  end

  def test_returns_unknown_data_error_if_lunch_year_does_not_exist
    e = EconomicProfile.new(economic_data)

    assert_raises(UnknownDataError) { e.free_or_reduced_price_lunch_percentage_in_year("popsicle") }
  end

  def test_can_find_free_or_reduced_price_lunch_number_in_year
    e = EconomicProfile.new(economic_data)

    assert_equal 100, e.free_or_reduced_price_lunch_number_in_year(2014)
  end

  def test_returns_unknown_data_error_if_lunch_number_in_year_does_not_exist
    e = EconomicProfile.new(economic_data)

    assert_raises(UnknownDataError) { e.free_or_reduced_price_lunch_number_in_year(3.14159) }
  end

  def test_can_find_title_i_in_year
    e = EconomicProfile.new(economic_data)

    assert_equal 0.543, e.title_i_in_year(2015)
  end

  def test_returns_unknown_data_error_if_title_i_year_does_not_exist
    e = EconomicProfile.new(economic_data)

    assert_raises(UnknownDataError) { e.title_i_in_year(1492) }
  end


  def economic_data
  {:median_household_income => {[2009, 2015] => 50000, [2013, 2014] => 60000},
              :children_in_poverty => {2012 => 0.1845, 2013 => 0.845, 2014 => 0.145},
              :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
              :title_i => {2015 => 0.543},
              :name => "ACADEMY 20"
             }
  end
end

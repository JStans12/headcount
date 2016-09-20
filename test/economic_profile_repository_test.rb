require './test_helper'
require './lib/economic_profile_repository'

class TestEconomicProfileRepository < Minitest::Test

  def test_inits_with_empty_economic_profiles_hash
    er = EconomicProfileRepository.new
    assert_equal ({}), er.economic_profiles
  end

  def test_find_by_name_finds_economic_profiles
    ep = EconomicProfileRepository.new
    ep.economic_profiles["ACADEMY 20"] = EconomicProfile.new({:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
                                                              :children_in_poverty => {2012 => 0.1845},
                                                              :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
                                                              :title_i => {2015 => 0.543},
                                                              :name => "ACADEMY 20"
                                                             })

   assert_equal EconomicProfile, ep.find_by_name("ACADEMY 20").class
   assert_equal "ACADEMY 20", ep.find_by_name("ACADEMY 20").name
  end

  def test_load_data_loads_economic_profile_repository
    epr = EconomicProfileRepository.new
    files_by_type = {
      :economic_profile => {
      :median_household_income => "./data/Median household income.csv",
      :children_in_poverty => "./data/School-aged children in poverty.csv",
      :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
      :title_i => "./data/Title I students.csv"
    }
    }

    assert epr.economic_profiles.empty?

    epr.load_data(files_by_type)

    refute epr.economic_profiles.empty?
  end

  def test_load_data_creates_economic_profile_objects
    epr = EconomicProfileRepository.new
    files_by_type = {
      :economic_profile => {
      :median_household_income => "./data/Median household income.csv",
      :children_in_poverty => "./data/School-aged children in poverty.csv",
      :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
      :title_i => "./data/Title I students.csv"
    }
    }

    epr.load_data(files_by_type)
    ep = epr.find_by_name("ACADEMY 20")

    assert_equal EconomicProfile, ep.class
  end

  def test_find_file_names_creates_arrays_of_file_names
    epr = EconomicProfileRepository.new
    files_by_type = {
      :economic_profile => {
      :median_household_income => "./data/Median household income.csv",
      :children_in_poverty => "./data/School-aged children in poverty.csv"
    }
    }

    assert_equal [:economic_profile, :median_household_income, "./data/Median household income.csv"], epr.find_file_names(files_by_type)[0]
  end


end

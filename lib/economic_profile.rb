require_relative '../lib/unknown_data_error'
require 'pry'

class EconomicProfile
  attr_accessor :name, :data

  def initialize(data)
    @data = nil
    @name = data[:name]
    assign_data(data)
  end

  def assign_data(data)
    data_name = data[:name]
    data.delete(:name)
    @data = {data_name => data}
  end

  def median_household_income_in_year(year)
    incomes = @data[name][:median_household_income].keys.reduce([]) do |result, range|
      expanded_range = (range[0]..range[1]).to_a
      result << @data[name][:median_household_income][range] if expanded_range.include?(year)
      result
    end
    raise UnknownDataError.new("Unknown Data Error") if incomes.empty?
    incomes.reduce(:+) / incomes.length
  end

  def median_household_income_average
    incomes = @data[name][:median_household_income].keys.reduce([]) do |result, range|
      result << @data[name][:median_household_income][range]
      result
    end
    incomes.reduce(:+) / incomes.length
  end

  def children_in_poverty_in_year(year)
    unless @data[name][:children_in_poverty].keys.include?(year)
      raise UnknownDataError.new("Unknown Data Error")
    end
    @data[name][:children_in_poverty][year]
  end

  def free_or_reduced_price_lunch_percentage_in_year(year)
    unless @data[name][:free_or_reduced_price_lunch].keys.include?(year)
      raise UnknownDataError.new("Unknown Data Error")
    end
    @data[name][:free_or_reduced_price_lunch][year][:percentage]
  end

  def free_or_reduced_price_lunch_number_in_year(year)
    unless @data[name][:free_or_reduced_price_lunch].keys.include?(year)
      raise UnknownDataError.new("Unknown Data Error")
    end
    @data[name][:free_or_reduced_price_lunch][year][:total]
  end

  def title_i_in_year(year)
    unless @data[name][:title_i].keys.include?(year)
      raise UnknownDataError.new("Unknown Data Error")
    end
    @data[name][:title_i][year]
  end
end

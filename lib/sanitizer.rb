require_relative '../lib/truncate'
require 'pry'

module Sanitizer
  include Truncate
  extend self

  def clean_line(line, file_name)
    line[:timeframe] = clean_timeframe(line[:timeframe])
    line[:data] = clean_data(line[:data], file_name, line) if line[:data]
    line[:score] = clean_score(line[:score]) if line[:score]
    line[:location] = clean_location(line[:location])
    line[:race_ethnicity] = clean_ethnicity(line[:race_ethnicity]) if line[:race_ethnicity]
    line
  end

  def clean_timeframe(timeframe)
    return timeframe.to_i                                 unless timeframe.include?('-')
    return timeframe.split('-').map! { |year| year.to_i } if timeframe.include?('-')
  end

  def clean_data(data, file_name, line)
    return data.to_i      if file_name[1] == :free_or_reduced_price_lunch && line[:dataformat] == "Number"
    return truncate(data) if file_name[0] == :statewide_testing || file_name[1] == :free_or_reduced_price_lunch && line[:dataformat] == "Percent"
    return data.to_f
  end

  def clean_score(score)
    score.downcase.to_sym
  end

  def clean_location(location)
    location.upcase
  end

  def clean_ethnicity(ethnicity)
    return :asian             if ethnicity == "Asian"
    return :all_students      if ethnicity == "All Students"
    return :black             if ethnicity == "Black"
    return :pacific_islander  if ethnicity == "Hawaiian/Pacific Islander"
    return :hispanic          if ethnicity == "Hispanic"
    return :native_american   if ethnicity == "Native American"
    return :two_or_more       if ethnicity == "Two or more"
    return :white             if ethnicity == "White"
  end
end

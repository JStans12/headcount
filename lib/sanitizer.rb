require_relative '../lib/truncate'
require 'pry'

module Sanitizer
  include Truncate
  extend self

  def clean_line(line, file_name)
    line[:timeframe] = clean_timeframe(line[:timeframe])
    line[:location] = clean_location(line[:location])

    if line[:data]
      line[:data] = clean_data(line[:data], file_name, line)
    end

    if line[:score]
      line[:score] = clean_score(line[:score])
    end

    if line[:race_ethnicity]
      line[:race_ethnicity] = clean_ethnicity(line[:race_ethnicity])
    end

    line
  end

  def clean_timeframe(tf)
    return tf.to_i                                 unless tf.include?('-')
    return tf.split('-').map! { |year| year.to_i } if tf.include?('-')
  end

  def clean_data(data, file_name, line)
    if file_name[1] == :free_or_reduced_price_lunch &&
       line[:dataformat] == "Number"

      return data.to_i
    end
    if file_name[0] == :statewide_testing ||
       (file_name[1] == :free_or_reduced_price_lunch &&
       line[:dataformat] == "Percent")

       return truncate(data)
    end
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

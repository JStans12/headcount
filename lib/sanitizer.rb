require_relative '../lib/truncate'
require 'pry'

module Sanitizer
  include Truncate
  extend self

  def clean_line(line)
    line[:timeframe] = clean_timeframe(line[:timeframe])
    # line[:data] = clean_data(line[:data]) if line[:data]
    line[:score] = clean_score(line[:score]) if line[:score]
    line
  end

  def clean_timeframe(timeframe)
    return timeframe.to_i                                 unless timeframe.include?('-')
    return timeframe.split('-').map! { |year| year.to_i } if timeframe.include?('-')
  end

  # def clean_data(data)
  #   return data.to_i      unless data.include?('.')
  #   return truncate(data) if data.include?('.')
  # end

  def clean_score(score)
    score.downcase.to_sym
  end
end

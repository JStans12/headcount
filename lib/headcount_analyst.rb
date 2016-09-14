require 'pry'

class HeadcountAnalyst

  def initialize(dr)
    @dr = dr
  end

  def kindergarten_participation_rate_variation(dname, against)
    binding.pry
    find_average_participation(@dr.find_by_name(dname)) / find_average_participation(@dr.find_by_name(against[:against])).to_f
  end

  def find_average_participation(district)
    district.enrollment.data[:kindergarten_participation].reduce(0) do |result, (key, value)|
      result += value
      result
    end /district.enrollment.data[:kindergarten_participation].values.length
  end
end

class EconomicProfile
  attr_accessor :name, :data

  def initialize(data)
    @name = data[:name]
    assign_data(data)
  end

  def assign_data(data)
    data_name = data.keys[1]
    @data = {data_name => data[data_name]}
  end

end

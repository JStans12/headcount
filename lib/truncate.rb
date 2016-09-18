module Truncate
  def truncate(float)
    (float.to_f*1000).floor/1000.0
  end
end

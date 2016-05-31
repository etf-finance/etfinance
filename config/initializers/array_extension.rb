class Array
  # Time#round already exists with different meaning in Ruby 1.9
  def test_for_test
  	self.each do |el|
  		puts el
  	end
  end

  def global_perf
    performance = 0
    self.each do |quote|
      performance += quote.perf
    end
    return performance
  end
end
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



  def batching
    index = 0

    array = Array.new

    while index < self.size
      quote_array = Array.new
      quote = self[index]
      quote_array = [quote]
      time = quote.round_time

      index += 1
      quote = self[index]

      while quote.present? && quote.round_time == time
        quote_array << quote
        index += 1
        quote = self[index]
      end

      array << quote_array

    end

    return array
  end

  def batch_to_data
    element = Hash.new
    global_pnl = 0
    self.each do |quote|
      name = quote.symbol.downcase+"_pnl"
      pnl = (((quote.ask + quote.bid)/2)-quote.previous_close)*quote.coef
      element[name] = pnl.round(2)
      global_pnl += pnl
    end
    element["pnl"] = global_pnl.round(2)
    element["value"] = ((self.global_perf).round(2))
    element["time"] = self.first.rounded_trade_time
    element["round_time"] = self.first.rounded_trade_time.to_time.round_off(10.minutes)
    element["first_quote_id"] = self.first.id
    element["last_quote_id"] = self.last.id
    return element
  end
end
class Quote < ActiveRecord::Base
	def self.create_batch(yahoo_data)
		quote_array = []
    yahoo_data.each do |el|
      quote = Quote.create(symbol: el.symbol, bid: el.bid.to_f, ask: el.ask.to_f, close: el.close.to_f, previous_close: el.previous_close.to_f, coef: Coefficient.where(symbol: el.symbol).where(expired: true).last.value, round_time: Time.zone.now.round_off(5.minutes))
      quote_array << quote
    end
    return quote_array
	end


	def diff
   	((self.bid + self.ask)/2) - self.close
  end

  def perf
    self.coef*self.diff
  end
end

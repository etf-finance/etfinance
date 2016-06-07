class Quote < ActiveRecord::Base
	def self.create_batch(yahoo_data)
		quote_array = []
    yahoo_data.each do |el|
      quote = Quote.create(symbol: el.symbol, bid: el.bid.to_f, ask: el.ask.to_f, close: el.close.to_f, previous_close: el.previous_close.to_f, coef: Coefficient.where(symbol: el.symbol).where(expired: true).last.value, round_time: Time.zone.now.round_off(10.minutes), source: "yahoo_finance_gem", last_trade_time: el.last_trade_time)
      quote_array << quote
    end
    return quote_array
	end

  def self.create_from_stock_quotes(symbols_array)
    stocks = StockQuote::Stock.json_quote(symbols_array)["quote"]

    stocks.each do |stock|
      Quote.create(source: "stock_quote", symbol: stock["symbol"], ask: stock["Ask"].to_f, bid: stock["Bid"].to_f, previous_close: stock["PreviousClose"].to_f, stock_quote_data: stock, round_time: Time.zone.now.round_off(10.minutes), coef: Coefficient.where(symbol: stock["symbol"]).where(expired: true).last.value, last_trade_time: stock["LastTradeTime"])
    end
  end


	def diff
   	((self.bid + self.ask)/2) - self.previous_close
  end

  def perf
    self.coef*self.diff
  end
end

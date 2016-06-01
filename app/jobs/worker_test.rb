class MyWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(5) }

  def perform
    if market_moment == "open"
      # SET UP MARKET ENVIRONMENT
      Time.zone = "America/New_York"
      symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]
      yahoo_client = YahooFinance::Client.new
      yahoo_data = yahoo_client.quotes(symbols_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name, :previous_close])
      quote_last_trade_date = DateTime.strptime(yahoo_data.first["last_trade_date"], "%m/%d/%Y").to_date


      stocks = StockQuote::Stock.json_quote(symbols_array)

      stocks.each do |stock|
        Quote.create(source: "stock_quote", symbol: stock["symbol"], ask: stock["Ask"].to_f, bid: stock["Bid"].to_f, previous_close: stock["PreviousClose"].to_f, stock_quote_data: stock, round_time: Time.zone.now.round_off(5.minutes), coef: Coefficient.where(symbol: stock["symbol"]).where(expired: true).last.value)
      end

      # CHECK IF THERE IS TRADE TODAY
      if true
      # if quote_last_trade_date == Date.today
        chart = Chart.new_or_last

        quote_array = Quote.create_batch(yahoo_data)

        chart.populate(quote_array)

        # chart.redesign

        puts "New quotes and chart designed"
        
      else
        puts "market closed today"
      end

    else

      puts market_moment
      puts Time.now.utc
    end
  end




  def market_moment
    Time.zone = "America/New_York"

    opening_time = Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 6, 5, 0)
    closing_time = Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 16, 8, 0)

    if Time.now.to_date.cwday == 6 || Time.now.to_date.cwday == 7
      return "close"
    elsif Time.zone.now > opening_time && Time.zone.now < closing_time - 5.minutes
      return "open"
    elsif Time.zone.now >= closing_time - 5.minutes && Time.now.utc < closing_time
      return "before_closing"
    else
      return "close"
    end
  end
end
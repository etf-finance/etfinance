class YahooWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(1) }

  def perform
    if market_moment == "open"
      # SET UP MARKET ENVIRONMENT
      Time.zone = "America/New_York"
      symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]
      yahoo_client = YahooFinance::Client.new
      yahoo_data = yahoo_client.quotes(symbols_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name, :previous_close])
      quote_last_trade_date = DateTime.strptime(yahoo_data.first["last_trade_date"], "%m/%d/%Y").to_date


      # chart = Chart.new_or_last

      quote_array = Quote.create_batch(yahoo_data)

      # chart.populate(quote_array)

        puts "New quotes and chart designed"

    else

      puts "yahoo finance worker done !"
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
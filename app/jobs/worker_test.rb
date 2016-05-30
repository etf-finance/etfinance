class MyWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(5) }

  def perform
    if market_moment == "open" && Time.now.to_date.cwday != 6 && Time.now.to_date.cwday != 7
      Time.zone = "America/New_York"
      symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]
      yahoo_client = YahooFinance::Client.new
      yahoo_data = yahoo_client.quotes(symbols_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name, :previous_close])

      quote_array = []
      yahoo_data.each do |el|
        quote = Quote.create(symbol: el.symbol, bid: el.bid.to_f, ask: el.ask.to_f, close: el.close.to_f, previous_close: el.previous_close.to_f, coef: Coefficient.where(symbol: el.symbol).where(expired: true).last.value, round_time: Time.zone.now.round_off(5.minutes))
        quote_array << quote
      end


      if Chart.last.present?
        chart = (Chart.last.created_at.day == Time.now.day) ? Chart.last : Chart.create
      else
        chart = Chart.create
      end

      data = chart.data
      element = data.find{|x| x["value"]==nil }
      element["value"] = ((global_perf(quote_array)).round(2))
      quote_array.each do |quote|
        element[(quote.symbol.downcase+"_ask")] = quote.ask
        element[(quote.symbol.downcase+"_bid")] = quote.bid
        element[(quote.symbol.downcase+"_close")] = quote.close
        element[(quote.symbol.downcase+"_previous_close")] = quote.previous_close
        element["quotes_array"] = symbols_array
      end
      element["time"] = quote_array.first.round_time
      element["first_quote_id"] = quote_array.first.id
      element["last_quote_id"] = quote_array.last.id
      chart.data = data
      

      # chart.data << obj
      chart.save

      chart.redesign
      

      puts "Done."
    else
      puts market_moment
      puts Time.now.utc
    end
  end



   def global_perf(array)
    perf = 0
    array.each do |el|
      perf += perf(el)
    end
    return perf
  end

  def perf(x)
    x.coef*diff(x)
  end

  def diff(x)
    ((x.bid.to_f + x.ask.to_f)/2) - x.close.to_f
  end


  def to_morris_array(hash, type)
    array = Array.new
    hash.each do |key, value|
      if type == "bar"
        obj = {date: key.strftime('%e %b' ), value: value}
      elsif type == "line"
        obj = {date: key, value: value}
      end
      array << obj
    end
    return array
  end


  def market_moment
    Time.zone = "America/New_York"

    opening_time = Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 6, 5, 0)
    # opening_time = Time.utc(Time.now.utc.year, Time.now.utc.month, Time.now.utc.day, 10, 0, 0) + 8.minutes
    closing_time = Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 16, 8, 0)
    if Time.zone.now > opening_time && Time.zone.now < closing_time - 5.minutes
      return "open"
    elsif Time.zone.now >= closing_time - 5.minutes && Time.now.utc < closing_time
      return "before_closing"
    else
      return "close"
    end
  end
end
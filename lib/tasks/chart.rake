namespace :chart do



  desc "populate Quote model"
  task picking_quotes: :environment do
  # disable_active_record_logger
    if market_moment == "open" && Time.now.to_date.cwday != 6 && Time.now.to_date.cwday != 7
      symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]
      yahoo_client = YahooFinance::Client.new
      yahoo_data = yahoo_client.quotes(symbols_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name, :previous_close])


      if Chart.last.present?
        chart = (Chart.last.created_at.day == Time.now.day) ? Chart.last : Chart.create
      else
        chart = Chart.create
      end

      element = chart.data.find{|x| x["value"]==nil }
      element["value"] = ((global_perf(yahoo_data)).round(2))
      

      # chart.data << obj
      chart.save
      
      yahoo_data.each do |el|
        Quote.create(symbol: el.symbol, bid: el.bid.to_f, ask: el.ask.to_f, close: el.close.to_f, previous_close: el.previous_close.to_f, coef: Coefficient.where(symbol: el.symbol).where(expired: true).last.value)
      end

      puts "Done."
    else
      puts "market close"
    end
  end



  desc "makes tomorrow_coef expired"
  task expired_coefficients: :environment do
  # disable_active_record_logger
  coefs = Coefficient.where(expired: false)
  coefs.each do |c|
    c.expired = true
    c.save
  end

  puts "Done."

  end


  desc "makes tomorrow_coef expired"
  task create_coefficients: :environment do
  # disable_active_record_logger
  symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]
  symbols_array.each do |symbol|
    c = Coefficient.create(symbol: symbol, value: (1+rand).round(1), expired: true)
    Coefficient.create(symbol: symbol, value: (c.value+0.1+rand).round(1), expired: false)
  end

  puts "Done."

  end




  def global_perf(array)
    perf = 0
    array.each do |el|
      perf += perf(el)
    end
    return perf
  end

  def perf(x)
    coef(x)*diff(x)
  end

  def diff(x)
    ((x.bid.to_f + x.ask.to_f)/2) - x.close.to_f
  end


  def coef(x)
    Coefficient.where(symbol: x.symbol).where(expired: true).last.value
  end


  def round_off(t, seconds = 60)
    Time.at((t.to_f / seconds).round * seconds).utc
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
    opening_time = Time.utc(Time.now.utc.year, Time.now.utc.month, Time.now.utc.day, ENV['OPENING_HOUR'], ENV['OPENING_MIN'], 0) + 8.minutes
    closing_time = Time.utc(Time.now.utc.year, Time.now.utc.month, Time.now.utc.day, ENV['CLOSING_HOUR'], ENV['CLOSING_MIN'], 0)
    if Time.now.utc > opening_time && Time.now.utc < closing_time - 5.minutes
      return "open"
    elsif Time.now.utc >= closing_time - 5.minutes && Time.now.utc < closing_time
      return "before_closing"
    else
      return "close"
    end
  end

end
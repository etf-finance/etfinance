namespace :chart do



  desc "populate Quote model"
  task picking_quotes: :environment do
  # disable_active_record_logger    
    if market_moment == "open" && Time.now.to_date.cwday != 6 && Time.now.to_date.cwday != 7
      Time.zone = "America/New_York"
      symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]
      yahoo_client = YahooFinance::Client.new
      yahoo_data = yahoo_client.quotes(symbols_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name, :previous_close, :last_trade_time])

      quote_array = Quote.create_batch(yahoo_data)

      chart = Chart.new_or_last

      chart.populate(quote_array)

      chart.redesign

      puts "populates from #{quote_array.first.id} to #{quote_array.last.id} : #{quote_array.size} valeurs "
    else
      puts market_moment
      puts Time.now.utc
    end
  end

  desc "populate Quote model"
  task stock_quotes: :environment do
  # disable_active_record_logger
    symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]
    Quote.create_from_stock_quotes(symbols_array)
    puts "from stock_quotes ok !!!!"
  end



  desc "populate Quote model"
  task both_quotes: :environment do
  # disable_active_record_logger
    symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]
    yahoo_client = YahooFinance::Client.new
    yahoo_data = yahoo_client.quotes(symbols_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name, :previous_close, :last_trade_price])
    Quote.create_batch(yahoo_data)
    Quote.create_from_stock_quotes(symbols_array)
    puts "from stock_quotes ok !!!!"
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
namespace :chart do
  desc "Update quotes in google spreadsheet"

  desc "populate Quote model"
  task new_quote: :environment do
  # disable_active_record_logger
    10.times do 
      yahoo_client = YahooFinance::Client.new
      data = yahoo_client.quotes(["AAPL"], [:ask, :bid, :last_trade_date])
      quote = Quote.create(value: data[0].ask.to_f*rand)

      chart = Chart.last.created_at.day == Time.now.day ? Chart.last : Chart.create
      chart.data << {date: quote.created_at, value: quote.value.round(2)}
      chart.save

      puts "Done."
    end
  end


  desc "populate Quote model"
  task picking_quotes: :environment do
  # disable_active_record_logger
      symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]
      yahoo_client = YahooFinance::Client.new
      data = yahoo_client.quotes(symbols_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name])

      cc = ChartController.new

      obj = {time: round_off(Time.now, 10.minutes), value: cc.global_perf(data)*rand}

      chart = Chart.last.created_at.day == Time.now.day ? Chart.last : Chart.create

      chart.data << obj
      chart.save
      
      data.each do |el|
        Quote.create(symbol: el.symbol, bid: el.bid.to_f, ask: el.ask.to_f, close: el.close.to_f)
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
    Coefficient.where(symbol: x.symbol).last.value
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
end
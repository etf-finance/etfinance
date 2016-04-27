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

  def calculation(value)
    return (rand*value) 
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
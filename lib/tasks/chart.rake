namespace :chart do
  desc "Update quotes in google spreadsheet"

  desc "populate Quote model"
  task new_quote: :environment do
  # disable_active_record_logger
    yahoo_client = YahooFinance::Client.new
    data = yahoo_client.quotes(["AAPL", "FB"], [:ask, :bid, :last_trade_date])
    quote = Quote.create(value: data[0].ask.to_f*rand)


    @main_picture = @car.car_pictures.where(main: true).present? ? @car.car_pictures.where(main: true).last : @car.car_pictures.first

    chart = Chart.last.created_at.day != Time.now.day ? Chart.last : Chart.create


    puts "Done."
  end

  def calculation(value)
    return (rand*value) 
  end
end
class StockWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(1) }

  def perform
      symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]
      Quote.create_from_stock_quotes(symbols_array)
      puts "stock quotes worker done !"
  end

end
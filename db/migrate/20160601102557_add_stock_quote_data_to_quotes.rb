class AddStockQuoteDataToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :stock_quote_data, :json
  end
end

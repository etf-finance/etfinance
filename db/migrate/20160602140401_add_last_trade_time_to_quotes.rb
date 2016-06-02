class AddLastTradeTimeToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :last_trade_time, :string
  end
end

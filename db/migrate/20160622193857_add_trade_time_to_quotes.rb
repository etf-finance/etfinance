class AddTradeTimeToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :trade_time, :datetime
  end
end

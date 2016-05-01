class AddBidAndAskAndCloseToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :bid, :float
    add_column :quotes, :ask, :float
    add_column :quotes, :close, :float
  end
end

class AddPreviousCloseToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :previous_close, :float
  end
end

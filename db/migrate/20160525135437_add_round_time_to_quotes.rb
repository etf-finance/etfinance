class AddRoundTimeToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :round_time, :datetime
  end
end

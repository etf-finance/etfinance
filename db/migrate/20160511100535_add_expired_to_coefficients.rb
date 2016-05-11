class AddExpiredToCoefficients < ActiveRecord::Migration
  def change
    add_column :coefficients, :expired, :boolean, default: false
  end
end

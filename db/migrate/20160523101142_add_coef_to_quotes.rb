class AddCoefToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :coef, :float
  end
end

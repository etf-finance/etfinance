class AddSymbolToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :symbol, :string
  end
end

class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.float :value

      t.timestamps null: false
    end
  end
end

class CreateGraphs < ActiveRecord::Migration
  def change
    create_table :graphs do |t|
      t.string :data

      t.timestamps null: false
    end
  end
end

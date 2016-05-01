class CreateCoefficients < ActiveRecord::Migration
  def change
    create_table :coefficients do |t|
      t.float :value
      t.string :symbol

      t.timestamps null: false
    end
  end
end

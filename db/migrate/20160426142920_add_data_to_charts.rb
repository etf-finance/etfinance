class AddDataToCharts < ActiveRecord::Migration
  def change
  	add_column :charts, :data, :json, array:true, default: []
  end
end

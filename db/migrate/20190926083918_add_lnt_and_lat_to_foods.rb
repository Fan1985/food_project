class AddLntAndLatToFoods < ActiveRecord::Migration[5.2]
  def change
    add_column :foods, :lat, :decimal
    add_column :foods, :lng, :decimal
  end
end

class AddLntAndLatToFoods < ActiveRecord::Migration[5.2]
  def change
    add_column :foods, :lat, :float
    add_column :foods, :lng, :float
  end
end

class AddStreetToLifeCoolerPois < ActiveRecord::Migration
  def change
    add_column :life_cooler_pois, :street, :string
  end
end

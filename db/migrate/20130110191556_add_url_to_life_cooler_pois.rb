class AddUrlToLifeCoolerPois < ActiveRecord::Migration
  def change
    add_column :life_cooler_pois, :url, :string
  end
end

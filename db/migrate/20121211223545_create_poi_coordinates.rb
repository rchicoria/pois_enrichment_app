class CreatePoiCoordinates < ActiveRecord::Migration
  def change
    create_table :poi_coordinates do |t|
      t.string :name
      t.string :lat
      t.string :lng
      t.string :uri

      t.timestamps
    end
  end
end

class CreatePois < ActiveRecord::Migration
  def change
    create_table :pois do |t|

      t.timestamps
    end
  end
end

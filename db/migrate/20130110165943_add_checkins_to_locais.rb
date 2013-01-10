class AddCheckinsToLocais < ActiveRecord::Migration
  def change
    add_column :locais, :checkins, :integer
  end
end

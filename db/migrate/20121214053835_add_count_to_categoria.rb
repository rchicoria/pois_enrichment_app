class AddCountToCategoria < ActiveRecord::Migration
  def change
    add_column :categoria, :count, :integer
  end
end

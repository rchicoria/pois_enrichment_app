class ChangeTokenCategoryIdToCategoriaId < ActiveRecord::Migration
  def up
  	rename_column :tokens, :category_id, :categoria_id
  end

  def down
  	rename_column :tokens, :categoria_id, :category_id
  end
end

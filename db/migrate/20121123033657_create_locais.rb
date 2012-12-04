class CreateLocais < ActiveRecord::Migration
  def up
  	create_table :locais do |t|
      t.string  :nome
      t.string  :url_imagem
      t.string  :lat
      t.string  :lng
      t.string  :type
      t.integer :municipio
      t.integer :distrito

      t.boolean :bandeira_azul
    end
  end

  def down
  	drop_table :locais
  end
end

class CreateLifeCoolerPois < ActiveRecord::Migration
  def change
    create_table :life_cooler_pois do |t|
      t.string :nome
      t.string :url_imagem
      t.string :categoria_lc
      t.string :subcategoria_lc
      t.string :municipio
      t.string :distrito
      t.text :descricao
      t.string :telefone
      t.string :website
      t.string :horario
      t.text :especialidades
      t.string :tipo_restaurante
      t.string :preco_medio
      t.string :lotacao
      t.string :tipo_musica
      t.string :ano_construcao
      t.string :servicos_cultura
      t.boolean :bandeira_azul

      t.timestamps
    end
  end
end

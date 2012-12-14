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
      t.text    :descricao
      t.string  :telefone
      t.string  :website
      t.string  :horario

      # Restaurantes
      t.text    :especialidades
      t.string  :tipo_restaurante
      t.string  :preco_medio

      # Bares
      t.string  :lotacao
      t.string  :tipo_musica

      # Monumentos
      t.string  :ano_construcao

      # Cultura
      t.string  :servicos_cultura

      # Praias
      t.boolean :bandeira_azul
    end
  end

  def down
  	drop_table :locais
  end
end
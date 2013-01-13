class FixLifecoolerPoisColumnNames < ActiveRecord::Migration
  def up
  	rename_column :life_cooler_pois, :nome, :nome_lc
  	rename_column :life_cooler_pois, :especialidades, :especialidades_lc
  	rename_column :life_cooler_pois, :descricao, :descricao_lc
  	rename_column :life_cooler_pois, :distrito, :distrito_lc
  	rename_column :life_cooler_pois, :municipio, :municipio_lc
  	rename_column :life_cooler_pois, :servicos_cultura, :servicos_cultura_lc
  	rename_column :life_cooler_pois, :tipo_musica, :tipo_musica_lc
  	rename_column :life_cooler_pois, :tipo_restaurante, :tipo_restaurante_lc
  end

  def down
  	rename_column :life_cooler_pois, :nome_lc, :nome
  	rename_column :life_cooler_pois, :especialidades_lc, :especialidades
  	rename_column :life_cooler_pois, :descricao_lc, :descricao
  	rename_column :life_cooler_pois, :distrito_lc, :distrito
  	rename_column :life_cooler_pois, :municipio_lc, :municipio
  	rename_column :life_cooler_pois, :servicos_cultura_lc, :servicos_cultura
  	rename_column :life_cooler_pois, :tipo_musica_lc, :tipo_musica
  	rename_column :life_cooler_pois, :tipo_restaurante_lc, :tipo_restaurante
  end
end

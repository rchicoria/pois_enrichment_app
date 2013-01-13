# encoding: UTF-8

class LifeCoolerPoi < ActiveRecord::Base
  attr_accessible :ano_construcao, :bandeira_azul, :categoria_lc, :descricao_lc, :distrito_lc, :especialidades_lc, :horario, :lotacao, :municipio_lc, :nome_lc, :preco_medio, :servicos_cultura_lc, :subcategoria_lc, :telefone, :tipo_musica_lc, :tipo_restaurante_lc, :url_imagem, :website

  searchable do
    text :nome_lc, :boost => 5.0
    text :descricao_lc
    text :categoria_lc
    text :subcategoria_lc
    text :distrito_lc
    text :municipio_lc
    text :especialidades_lc
    text :servicos_cultura_lc
    text :tipo_musica_lc
    text :tipo_restaurante_lc
  end

  def nome
    nome_lc
  end

  def descricao
    descricao_lc
  end

  def especialidades
    especialidades_lc
  end

  def servicos_cultura
    servicos_cultura_lc
  end

  def tipo_musica
    tipo_musica_lc
  end

  def tipo_restaurante
    tipo_restaurante_lc
  end

  def distrito
    distrito_lc
  end

end

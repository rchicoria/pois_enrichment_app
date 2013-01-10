class Local < ActiveRecord::Base
  attr_accessible :nome, :url_imagem, :lat, :lng, :servicos, :type, :municipio, :distrito, :descricao, :telefone, :website, :horario, :especialidades, :tipo_restaurante, :preco_medio, :lotacao, :tipo_musica, :ano_construcao, :servicos_cultura, :bandeira_azul

  attr_accessor :info, :info2, :info3

  set_table_name "locais"
  has_many :servicos
end
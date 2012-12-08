class Local < ActiveRecord::Base
  attr_accessible :nome, :url_imagem, :lat, :lng, :servicos

  set_table_name "locais"
  has_many :servicos
end
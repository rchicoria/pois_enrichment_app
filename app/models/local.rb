class Local < ActiveRecord::Base
  attr_accessible :nome, :url_imagem, :lat, :lng, :servicos

  attr_accessor :info, :info2, :info3

  set_table_name "locais"
  has_many :servicos
end
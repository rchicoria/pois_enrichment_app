class Servico < ActiveRecord::Base
  attr_accessible :nome
  belongs_to :local
end

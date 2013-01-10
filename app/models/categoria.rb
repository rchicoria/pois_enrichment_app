class Categoria < ActiveRecord::Base
  attr_accessible :nome, :count
  has_many :tokens
end

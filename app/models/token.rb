class Token < ActiveRecord::Base
  attr_accessible :categoria_id, :freq, :name

  belongs_to :categoria
end
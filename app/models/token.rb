class Token < ActiveRecord::Base
  attr_accessible :category_id, :freq, :name

  belongs_to :categoria
end
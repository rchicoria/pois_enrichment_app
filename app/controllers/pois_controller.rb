class PoisController < ApplicationController
	def index
		@pois = Poi.find_by("district"=>35, :category=>19)
	end
end

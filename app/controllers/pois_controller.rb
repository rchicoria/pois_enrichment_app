class PoisController < ApplicationController
	def index
		@pois = Poi.find_by("district"=>35, :category=>215)
	end
end
